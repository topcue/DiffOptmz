#!/bin/bash

BINKIT_ROOT="dep/BinKit"

echo "[*] Cleanup dep directory"
rm -rf dep && mkdir -p dep

echo "[*] Clone BinKit repository"
git clone https://github.com/SoftSec-KAIST/BinKit $BINKIT_ROOT

echo "[*] Overwrite some scripts"
cp scripts/env.sh $BINKIT_ROOT/scripts/env.sh
cp scripts/setup_clang.sh $BINKIT_ROOT/scripts/setup_clang.sh

echo "[*] Set BinKit env to build tools"
source $BINKIT_ROOT/scripts/env.sh
$BINKIT_ROOT/scripts/install_default_deps.sh
$BINKIT_ROOT/scripts/setup_ctng.sh

echo "[*] Overwrite cntg_conf"
rm -rf $BINKIT_ROOT/ctng_conf
cp -r scripts/ctng_conf $BINKIT_ROOT/ctng_conf

echo "[*] Build GCC"
$BINKIT_ROOT/scripts/setup_gcc.sh

echo "[*] Cleanup ctng"
$BINKIT_ROOT/scripts/cleanup_ctng.sh

echo "[*] Build CLANG"
$BINKIT_ROOT/scripts/setup_clang.sh

# EOF
