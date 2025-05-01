#!/bin/sh
#
# A packer provisioner script to that can extract and execute base64 encoded shell scripts contained in instance
# metadata.

info()
{
    echo "$0: INFO: $*" >&2
}

error()
{
    echo "$0: ERROR: $*" >&2
    exit 1
}

extract_b64_attribute()
{
    output="$(mktemp)" || error "Failed to create temporary output file: $?"
    response_code="$(curl -sSLo "${output}" --retry 5 -w '%{response_code}' -H 'Metadata-Flavor: Google' "http://169.254.169.254/computeMetadata/v1/instance/attributes/${1}?alt=text")"
    case "${response_code}" in
        "200")
            base64 -d < "${output}" > "${2}" || error "Failed to extract base64 encoded script for ${1}: $?"
            ;;
        "404")
            # 404 is an expected result when looping through potential keys
            ;;
        *)
            error "Failed to download script ${1}: HTTP status ${response_code}, exit code $?"
            ;;
    esac
    rm -f "${output}" || error "Failed to delete temporary output file: $?"
    return 0
}

[ "$(id -u)" -eq 0 ] || error 'Script must be run as root. Use sudo or su before running this script.'

info "Updating package lists and installing prerequisites"
apt update || error "Failed to update package lists: $?"
apt install --yes --no-install-recommends --no-install-suggests --no-upgrade coreutils curl gnupg2 ca-certificates lsb-release || \
    error "Failed to install prerequisite packages: $?"

info "Executing scripts from metadata"
for index in $(seq 0 9); do
    script="$(mktemp)" || error "Failed to create temporary file for script at index ${index}: $?"
    extract_b64_attribute "${index}_provision_sh" "${script}"
    if [ -s "${script}" ]; then
        sh "${script}" || error "Error executing script at index ${index}: $?"
    fi
    rm -f "${script}" || error "Failed to delete temporary file for script at index ${index}: $?"
done

info "Installation complete"
