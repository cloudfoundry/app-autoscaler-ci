#!/bin/bash

set -e -x

source ~/.bashrc

echo "=====ENVIRONMENT====="
printenv

cd dea_next

export GOPATH=$PWD/go

go test -i -race directoryserver
go test -v -race directoryserver
