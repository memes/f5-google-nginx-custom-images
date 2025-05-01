from typing import Dict

import pytest
import requests
from testinfra.host import Host

labels = {'expect-nginx-api': 'disabled', 'expect-nginx-one': 'disabled'}


@pytest.fixture
def hosts(find_hosts, label_filter) -> Dict[str, Host]:
    """Finds the Compute Engine instances in the test harness project with matching labels."""
    filter = label_filter(labels=labels)
    return find_hosts(filter=filter)


@pytest.fixture
def endpoints(find_endpoints, label_filter) -> Dict[str, str]:
    """Finds the public HTTP endpoints for Compute Engine instances in the test harness project with matching labels."""
    filter = label_filter(labels=labels)
    return find_endpoints(filter=filter)


def test_hosts(hosts: Dict[str, Host], nginx_api_disabled, nginx_one_disabled) -> None:
    """Asserts that the labeled Compute Engine instances meet expectations for NGINX+ API and NGINX One registration."""
    assert len(hosts) > 0

    for name, host in hosts.items():
        print('Validating {}'.format(name))
        nginx_api_disabled(name, host)
        nginx_one_disabled(name, host)


def test_services(endpoints: Dict[str, str]) -> None:
    """Asserts that the labeled Compute Engine instances have exposed NGINX service on port 80."""
    assert len(endpoints) > 0

    for name, endpoint in endpoints.items():
        print('Testing {}'.format(name))
        resp = requests.get('http://{0}/'.format(endpoint))
        assert resp.status_code == 200, 'HTTP response from {} has unexpected status code'.format(
            name)
