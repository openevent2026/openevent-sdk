# openevent-sdk

[English version](README.md)

`openevent-sdk` 包含 OpenEvent 共享的 Protocol Buffers 协议、API 契约文档
和 Python SDK。

Python SDK 是生成的 gRPC stub 的轻量封装，不增加应用层业务语义。

## 目录结构

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

`src/openevent/sdk/proto/openevent_pb2*.py` 由 `proto/openevent.proto` 生成，不进 git；
构建、测试或本地调试前由脚本生成到该目录。

## 构建和测试

构建、测试和安装统一通过 `make` 执行。`build/` 是保留的临时构建目录，只放构建依赖、测试依赖、缓存和临时文件；最终 wheel 输出到 `dist/`。

本地调试前生成 Python protobuf 模块：

```bash
make init
```

只构建、不安装到当前 Python 环境：

```bash
make build
```

构建完成后，wheel 位于：

```text
dist/openevent_sdk-0.3.0-py3-none-any.whl
```

构建并安装生成的 wheel：

```bash
make install
```

需要指定安装路径时，通过 `INSTALL_ARGS` 传递 `pip install` 参数：

```bash
make install INSTALL_ARGS="--target /opt/openevent-sdk"
make install INSTALL_ARGS="--prefix /opt/openevent-sdk"
```

运行测试；当前没有测试文件时会执行 SDK 导入和 protobuf smoke check：

```bash
make test
```

清理构建产物和临时文件：

```bash
make clean
```

## 文档

- [协议定义](proto/openevent.proto)
- [使用指南](docs/USAGE_cn.md)
- [API 契约](docs/API_cn.md)
- [Python SDK 入口](src/openevent/sdk/client.py)

`docs/API.md` 只描述公开字段、RPC 行为、错误语义和兼容性建议，不记录服务端
实现细节。
