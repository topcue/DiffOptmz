#!/bin/bash

wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz
tar -xf clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz

mv clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04 llvm-12
rm clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz

# EOF

