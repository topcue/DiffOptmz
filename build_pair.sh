#!/bin/bash

WORKSPACE=$(pwd)
TOOL_PATH="$WORKSPACE/dep/tools/"

NUM_JOBS=8
MAX_JOBS=8
export NUM_JOBS MAX_JOBS

BASE_PATH="$WORKSPACE/target/binutils"
RESULT_PATH="$WORKSPACE/result"

ARCH_X86="i686-ubuntu-linux-gnu"
ARCH_X8664="x86_64-ubuntu-linux-gnu"
ARCH_ARM="arm-ubuntu-linux-gnueabi"
ARCH_ARM64="aarch64-ubuntu-linux-gnu"
ARCH_MIPS="mipsel-ubuntu-linux-gnu"
ARCH_MIPS64="mips64el-ubuntu-linux-gnu"

OPTIONS=""
EXTRA_CFLAGS=""
EXTRA_LDFLAGS=""

argc="$#"
argv1="$1"
argv2="$2"

COMPILER="gcc"
ARCH="x86_64"

if [ "$argc" -eq 1 ]; then
    COMPILER="$argv1"
elif [ "$argc" -eq 2 ]; then
    COMPILER="$argv1"
    ARCH="$argv2"
fi

if [[ $COMPILER != "gcc" && $COMPILER != "clang" ]]; then
    echo "[-] usage: ./build_pair compiler arch"
    exit 0
fi

echo "[*] Compiler: $COMPILER"
echo "[*] Arch: $ARCH"

if [ $ARCH == "x86_32" ]; then
  ARCH_PREFIX=$ARCH_X86
  OPTIONS="${OPTIONS} -m32"
  ELFTYPE="ELF 32-bit LSB"
  ARCHTYPE="Intel 80386"
elif [ $ARCH == "x86_64" ]; then
  ARCH_PREFIX=$ARCH_X8664
  ELFTYPE="ELF 64-bit LSB"
  ARCHTYPE="x86-64"
elif [ $ARCH == "arm_32" ]; then
  ARCH_PREFIX=$ARCH_ARM
  ELFTYPE="ELF 32-bit LSB"
  ARCHTYPE="ARM, EABI5"
elif [ $ARCH == "arm_64" ]; then
  ARCH_PREFIX=$ARCH_ARM64
  ELFTYPE="ELF 64-bit LSB"
  ARCHTYPE="ARM aarch64"
elif [ $ARCH == "mips_32" ]; then
  ARCH_PREFIX=$ARCH_MIPS
  OPTIONS="${OPTIONS} -mips32r2"
  ELFTYPE="ELF 32-bit LSB"
  ARCHTYPE="MIPS, MIPS32"
elif [ $ARCH == "mips_64" ]; then
  ARCH_PREFIX=$ARCH_MIPS64
  OPTIONS="${OPTIONS} -mips64r2"
  ELFTYPE="ELF 64-bit LSB"
  ARCHTYPE="MIPS, MIPS64"
fi

if [[ $COMPILER =~ "clang" ]]; then
    # fix compiler version for clang
    COMPVER="8.2.0"
    export PATH="${TOOL_PATH}/clang/${COMPILER}/bin:${PATH}"
fi

COMPVER="8.2.0"
export PATH="${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}/bin:${PATH}"
SYSROOT="${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}/${ARCH_PREFIX}/sysroot"
SYSTEM="${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER}/${ARCH_PREFIX}/sysroot/usr/include"

COMPILER_OPT=""
COMPILER_OPT+=" -O1"

if [[ $COMPILER =~ "gcc" ]]; then
    CMD=""
    CMD="--host=\"${ARCH_PREFIX}\""
    CMD="${CMD} CFLAGS=\""
    CMD="${CMD} -isysroot ${SYSROOT} -isystem ${SYSTEM} -I${SYSTEM}"
    CMD="${CMD} ${COMPILER_OPT}"
    CMD="${CMD} ${OPTIONS}\""
    CMD="${CMD} LDFLAGS=\"${OPTIONS} ${EXTRA_LDFLAGS}\""
    CMD="${CMD} AR=\"${ARCH_PREFIX}-gcc-ar\""
    CMD="${CMD} RANLIB=\"${ARCH_PREFIX}-gcc-ranlib\""
    CMD="${CMD} NM=\"${ARCH_PREFIX}-gcc-nm\""
    CMD="${CMD} --disable-gdb --disable-gdbserver --disable-sim"
elif [[ $COMPILER =~ "clang" ]]; then
    CMD="--host=\"${ARCH_PREFIX}\""

    # ------------------- compile with CC="clang --target=" -----------------
    # clang needs to compile with this ...
    # if [[ $CCTARGET == "CCTARGET" ]]; then
    CMD="${CMD} CC=\"clang --target=${ARCH_PREFIX}"
    CMD="${CMD} --gcc-toolchain=${TOOL_PATH}/${ARCH_PREFIX}-${COMPVER} \""
    CMD="${CMD} CFLAGS=\" "
    CMD="${CMD} -isysroot ${SYSROOT} -isystem ${SYSTEM} -I${SYSTEM}"
    CMD="${CMD} -foptimization-record-file=opt.txt\""
    CMD="${CMD} ${COMPILER_OPT}"
    CMD="${CMD} ${OPTIONS}\""
    CMD="${CMD} LDFLAGS=\"${OPTIONS} ${EXTRA_LDFLAGS}\""
    CMD="${CMD} AR=\"llvm-ar\""
    CMD="${CMD} RANLIB=\"llvm-ranlib\""
    CMD="${CMD} NM=\"llvm-nm\""
    CMD="${CMD} --disable-gdb --disable-gdbserver --disable-sim"
fi

AUTO="autoconf"
CONF="./configure --prefix=\"${BASE_PATH}/install\" --build=x86_64-linux-gnu ${CMD}"
MAKE="make -j 8 -l 8"
INS="make install"

##! clean up
cd $BASE_PATH
make clean >/dev/null && make distclean >/dev/null

rm -rf $RESULT_PATH && mkdir -p $RESULT_PATH
rm -rf $BASE_PATH/install && mkdir -p $BASE_PATH/install

##! autoconf
if [[ "$COMPILER" -eq "clang" ]]; then
    eval $AUTO
fi

##! configure
echo "[*] CONF: $CONF"
eval $CONF -q >/dev/null

##! make
echo "[*] MAKE: $MAKE"
eval $MAKE >/dev/null

##! make install
echo "[*] INS: $INS"
eval $INS >/dev/null

cp -r $BASE_PATH/install/bin/* $RESULT_PATH/

# EOF

