from typing import Dict

import pytest
from google.cloud.compute_v1.types import Image

labels = {}


@pytest.fixture
def images(find_images, label_filter) -> Dict[str, Image]:
    """Finds the custom Compute Engine images in the test harness project with matching labels."""
    filter = label_filter(labels=labels)
    return find_images(filter=filter)


def test_images(images: Dict[str, Image]) -> None:
    """Verifies that custom NGINX+ images have retained marketplace identifier."""
    assert len(images) > 0

    for name, image in images.items():
        print('Validating {}'.format(name))
        assert any('nginx-public' in x for x in image.licenses)
