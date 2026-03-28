#!/bin/bash
cd "$(dirname "$0")/.."
python -m grpc_tools.protoc \
  -I proto/ \
  --python_out=grpc/generated/ \
  --grpc_python_out=grpc/generated/ \
  proto/matching.proto
