#!/bin/bash -eu
if [ -z "$TOOL_PATH" ]; then
    echo "env \$TOOL_PATH should be defined first."
    echo "source \$BINKIT_ROOT/scripts/env.sh"
    exit
fi

declare -a VERSIONS=(
    "8.0.0"
)
SYSNAME="x86_64-linux-gnu-ubuntu-16.04"
CLANG_ROOT="$TOOL_PATH/clang"
LLVM_OBFUS_PATH="$CLANG_ROOT/obfuscator"
CLANG_OBFUS_PATH="$CLANG_ROOT/clang-obfus"

mkdir -p "$CLANG_ROOT"
cd "$CLANG_ROOT"

for VER in "${VERSIONS[@]}"; do
    echo "Setting clang-${VER} =========="
    CLANG_URL="http://releases.llvm.org/${VER}/clang+llvm-${VER}-"
    CLANG_TAR="${CLANG_ROOT}/clang-${VER}.tar.xz"
    CLANG_PATH="${CLANG_ROOT}/clang-${VER%.*}"
    if [[ "${VER%%\.*}" -gt 8 ]]; then
	CLANG_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${VER}/clang+llvm-${VER}-"
    fi

    if [[ ! -d "$CLANG_PATH" ]]; then
        # If the compilation fails, check if the href contains a correct SYSNAME.
        # For example, the link of 5.0.0 or 5.0.1 contains a SYSNAME,
        # "linux-x86_64-ubuntu16.04" instead of "x86_64-linux-gnu-ubuntu-16.04".
        if [[ ! -f "$CLANG_TAR" ]]; then
            wget "${CLANG_URL}${SYSNAME}.tar.xz" -O "$CLANG_TAR"
        fi

        CLANG_VER_DIR=$(tar tf ${CLANG_TAR} | head -n 1)
        tar xf "${CLANG_TAR}"
        mv "$CLANG_VER_DIR" "$CLANG_PATH"
    fi
done
