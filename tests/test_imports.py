from __future__ import annotations

from openevent.sdk import AdminClient, OpenEventClient
from openevent.sdk.proto import openevent_pb2


def test_public_imports_and_constants() -> None:
    assert AdminClient
    assert OpenEventClient
    assert openevent_pb2.VISIBILITY_PUBLIC == 0
    assert openevent_pb2.VISIBILITY_PROTECTED == 1
    assert openevent_pb2.VISIBILITY_PRIVATE == 2
    assert openevent_pb2.CHANNEL_FILTER_ALL == 0
