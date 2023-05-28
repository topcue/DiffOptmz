#!/bin/bash

BINKIT_ROOT="target/binutils"

rm -rf target && mkdir -p target

cd target

git clone https://github.com/bminor/binutils-gdb
mv binutils-gdb binutils

cd binutils

git checkout binutils-2_38

# EOF
