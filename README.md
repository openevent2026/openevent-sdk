# openevent-sdk

[中文版](README_cn.md)

`openevent-sdk` contains the shared OpenEvent Protocol Buffers schema, API
contract documentation, and Python SDK.

The Python SDK is a lightweight wrapper around generated gRPC stubs. It does not
add application-level business semantics.

## Directory Layout

```text
openevent-sdk/
├── proto/
│   └── openevent.proto
├── docs/
│   └── API.md
├── Makefile
├── build.sh
├── generate_python_proto.sh
├── test.sh
├── src/
│   └── openevent/
│       └── sdk/
│           ├── __init__.py
│           ├── client.py
│           └── proto/
│               └── __init__.py
└── pyproject.toml
```

`src/openevent/sdk/proto/openevent_pb2*.py` is generated from
`proto/openevent.proto` and is not tracked by Git. Generate it before local
debugging, builds, or tests.

## Build and Test

Build, test, and install tasks are wrapped by `make`. The `build/` directory is
reserved for temporary build dependencies, test dependencies, caches, and
temporary files. Wheel artifacts are written to `dist/`.

Generate Python protobuf modules for local debugging:

```bash
make init
```

Build only, without installing into the current Python environment:

```bash
make build
```

The wheel is written to:

```text
dist/openevent_sdk-0.3.0-py3-none-any.whl
```

Build and install the generated wheel:

```bash
make install
```

Pass `pip install` options through `INSTALL_ARGS` when a custom install path is
needed:

```bash
make install INSTALL_ARGS="--target /opt/openevent-sdk"
make install INSTALL_ARGS="--prefix /opt/openevent-sdk"
```

Run tests. If there are no test files yet, this runs SDK import and protobuf
smoke checks:

```bash
make test
```

Run end-to-end tests against a real OpenEvent server:

```bash
OPENEVENT_SERVER_BIN=<openevent_server_binary> make e2e
```

End-to-end tests use the `openevent-sdk>=0.3.0` package already installed in
the current Python environment. They do not install this repository into a
temporary dependency directory or generate SDK protobuf files.

Clean build products and temporary files:

```bash
make clean
```

## Documentation

- [Protocol definition](proto/openevent.proto)
- [Usage guide](docs/USAGE.md)
- [API contract](docs/API.md)
- [Python SDK entry point](src/openevent/sdk/client.py)

`docs/API.md` only documents public fields, RPC behavior, error semantics, and
compatibility guidance. It does not describe server implementation details.
