#!/bin/bash

BINKIT_ROOT="dep/BinKit"

rm -rf dep && mkdir -p dep
git clone https://github.com/SoftSec-KAIST/BinKit $BINKIT_ROOT

cp scripts/env.sh $BINKIT_ROOT/scripts/env.sh
cp scripts/setup_clang.sh $BINKIT_ROOT/scripts/setup_clang.sh

source $BINKIT_ROOT/scripts/env.sh
$BINKIT_ROOT/scripts/install_default_deps.sh
$BINKIT_ROOT/scripts/setup_ctng.sh

rm -rf $BINKIT_ROOT/ctng_conf
cp -r scripts/ctng_conf $BINKIT_ROOT/ctng_conf

$BINKIT_ROOT/scripts/setup_gcc.sh
$BINKIT_ROOT/scripts/cleanup_ctng.sh
$BINKIT_ROOT/scripts/setup_clang.sh

# EOF
