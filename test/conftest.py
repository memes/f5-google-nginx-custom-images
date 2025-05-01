import json
from typing import Any, Dict, Optional

import pytest
import testinfra
from google.cloud import compute_v1
from google.cloud.compute_v1.types import Image, Instance


@pytest.fixture(scope="session")
def harness_values() -> Dict[str, Any]:
    """Extract the values written by tofu/terraform during resource creation."""
    with open("test/harness.json", mode='r') as harness:
        return json.load(harness)


@pytest.fixture(scope="session")
def project_id(harness_values: Dict[str, Any]) -> str:
    """Returns the project_id containing the BIG-IP resources."""
    assert harness_values['project_id']
    return harness_values['project_id']


@pytest.fixture(scope="session")
def prefix(harness_values: Dict[str, Any]) -> str:
    """Returns the test harness prefix string used to name resources."""
    assert harness_values['name']
    return harness_values['name']


@pytest.fixture(scope="session")
def zone(harness_values: Dict[str, Any]) -> str:
    """Returns the Compute Engine zone containing BIG-IP resources."""
    assert harness_values['zone']
    return harness_values['zone']


@pytest.fixture(scope="session")
def ssh_config(harness_values: Dict[str, Any]) -> str:
    """Returns the SSH config file to use for connections."""
    assert harness_values['ssh_config']
    return harness_values['ssh_config']


@pytest.fixture
def label_filter(prefix: str):

    def _builder(labels: Dict[str, str]) -> str:
        """Builds a CEL filter that will match resources with the supplied labels."""
        filters = list(map(lambda kv: 'labels.{0} = "{1}"'.format(
            kv[0], kv[1]), ({'use-case': 'custom-nginx-test'} | labels).items()))
        if len(filters) == 1:
            return filters[0]
        return ' AND '.join(map(lambda x: '({})'.format(x), filters))

    return _builder


@pytest.fixture
def find_images(project_id: str):

    def _builder(filter: Optional[str]) -> Dict[str, Image]:
        """Find the set of custom images and map into a labeled dictionary."""
        client = compute_v1.ImagesClient()
        req = compute_v1.ListImagesRequest(
            project=project_id,
            filter=filter
        )
        results = client.list(request=req)
        return {k: v for k, v in map(lambda image: (image.name, image), results)}

    return _builder


def get_public_address(instance: Instance) -> str:
    """Extract the public IP address of the instance's primary interface."""
    assert instance.network_interfaces
    interface = instance.network_interfaces[0]
    assert interface
    assert interface.access_configs
    assert interface.access_configs[0]
    return interface.access_configs[0].nat_i_p


@pytest.fixture
def find_hosts(project_id: str, zone: str, ssh_config: str):

    def _builder(filter: Optional[str]) -> Dict[str, testinfra.host.Host]:
        """Find the set of running instances and map into a labeled dictionary."""
        client = compute_v1.InstancesClient()
        req = compute_v1.ListInstancesRequest(
            project=project_id,
            zone=zone,
            filter=filter
        )
        results = client.list(request=req)
        return {k: v for k, v in map(lambda vm: (vm.name, testinfra.get_host(get_public_address(vm), ssh_config=ssh_config)), results)}

    return _builder


@pytest.fixture
def find_endpoints(project_id: str, zone: str):

    def _builder(filter: Optional[str]) -> Dict[str, str]:
        """Find the set of running instances and map into a labeled dictionary."""
        client = compute_v1.InstancesClient()
        req = compute_v1.ListInstancesRequest(
            project=project_id,
            zone=zone,
            filter=filter
        )
        results = client.list(request=req)
        return {k: v for k, v in map(lambda vm: (vm.name, get_public_address(vm)), results)}

    return _builder


@pytest.fixture(scope="session")
def nginx_api_enabled():

    def _builder(name: str, host: testinfra.host.Host) -> None:
        """Verifies that NGINX is running on the host with API enabled."""
        nginx = host.service('nginx')
        assert nginx.is_enabled
        assert nginx.is_running
        cmd = host.run(
            'curl -sSLo /dev/null -w "%{response_code}" -H "Content-Type: application/json" http://127.0.0.1/api/')
        assert cmd.rc == 0
        assert cmd.stdout == '200'

    return _builder


@pytest.fixture(scope="session")
def nginx_api_disabled():

    def _builder(name: str, host: testinfra.host.Host) -> None:
        """Verifies that NGINX is running on the host but with API disabled."""
        nginx = host.service('nginx')
        assert nginx.is_enabled
        assert nginx.is_running
        cmd = host.run(
            'curl -sSLo /dev/null -w "%{response_code}" -H "Content-Type: application/json" http://127.0.0.1/api/')
        assert cmd.rc == 0
        assert cmd.stdout == '404'

    return _builder


@pytest.fixture(scope="session")
def nginx_one_enabled():

    def _builder(name: str, host: testinfra.host.Host) -> None:
        """Verifies that NGINX Agent is running on the host and has registered with NGINX One."""
        agent = host.service('nginx-agent')
        assert agent.is_enabled
        assert agent.is_running
        cmd = host.run(
            'sudo grep -q "OneTimeRegistration completed" /var/log/nginx-agent/agent.log')
        assert cmd.rc == 0

    return _builder


@pytest.fixture(scope="session")
def nginx_one_disabled():

    def _builder(name: str, host: testinfra.host.Host) -> None:
        """Verifies that NGINX Agent is running on the host but hasn't registered to NGINX One."""
        agent = host.service('nginx-agent')
        assert agent.is_enabled
        assert agent.is_running
        cmd = host.run(
            'sudo grep -q "OneTimeRegistration completed" /var/log/nginx-agent/agent.log')
        assert cmd.rc != 0

    return _builder
