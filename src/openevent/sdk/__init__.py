from .client import AdminClient, OpenEventClient

try:
    from .proto import openevent_pb2, openevent_pb2_grpc
except ImportError:  # pragma: no cover
    openevent_pb2 = None
    openevent_pb2_grpc = None

__all__ = ["AdminClient", "OpenEventClient", "openevent_pb2", "openevent_pb2_grpc"]
