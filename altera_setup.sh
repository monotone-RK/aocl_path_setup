#!/bin/bash

################################################################################
# The MIT License (MIT)

# Copyright (c) 2017 Ryohei Kobayashi

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################  

add_path_() {
    local IFS=:
    local tmp=( $1 )

    for p in ${tmp[@]}; do
        if [[ "$p" == "$2" ]]; then
            echo "$1"
            return
        fi
    done

    echo "${1}:${2}"
}

del_path() {
    local IFS=:
    local tmp=($1)
    local ret=""

    for p in ${tmp[@]}; do
        if ! echo "$p" | grep -q -E "^$HOME/altera/|^$HOME/altera_pro/"; then
            if [[ -z "$ret" ]]; then
                ret="$p"
            else
                ret+=":${p}"
            fi
        fi
    done

    echo "$ret"
}

add_ldpath() {
    LD_LIBRARY_PATH="$(add_path_ "$LD_LIBRARY_PATH" "$1")"
}

add_path() {
    PATH="$(add_path_ "$PATH" "$1")"
}

case "$1" in
    standard) EDITION="altera";;
    pro) EDITION="altera_pro";;
    *)
        echo "Unknown edition: ${1}" >&2
        exit 1
        ;;
esac

case "$2" in
    16.0) V=16.0;;
    16.1) V=16.1;;
    *)
        echo "Unknown version: ${2}" >&2
        exit 1
        ;;
esac

case "$3" in
    de5|de5net|terasic/de5net)
        BOARD="de5net"
        BSP='terasic/de5net'
        ;;
    de5a|de5anet|terasic/de5anet)
        BOARD="de5anet"
        BSP='terasic/de5anet'
        ;;
    a10pl4|bittware/a10pl4)
        BOARD="a10pl4"
        BSP='bittware/a10pl4'
        ;;
    *)
        echo "Unknown board: ${3}" >&2
        exit 1
        ;;
esac

OS=linux64
OS_MODELSIM=linux
OS_NIOS2=x86_64-pc-linux-gnu

PREFIX="$HOME/${EDITION}"
ALTERA="${PREFIX}/${V}"
QUARTUS_ROOTDIR="${ALTERA}/quartus"
ALTERAOCLSDKROOT="${ALTERA}/hld"
SOPC_KIT_NIOS2="${ALTERA}/nios2eds"
AOCL_BOARD_PACKAGE_ROOT="${ALTERAOCLSDKROOT}/board/${BSP}"
QUARTUS_64BIT=1
LM_LICENSE_FILE="$HOME/altera_pro/16.0/hld/license.dat"

PATH="$(del_path "$PATH")"
LD_LIBRARY_PATH="$(del_path "$LD_LIBRARY_PATH")"

add_path "${QUARTUS_ROOTDIR}/bin"
add_path "${QUARTUS_ROOTDIR}/sopc_builder/bin"
add_path "${SOPC_KIT_NIOS2}/bin"
add_path "${SOPC_KIT_NIOS2}/sdk2/bin"
add_path "${SOPC_KIT_NIOS2}/bin/gnu/H-${OS_NIOS2}/bin"
add_path "${ALTERAOCLSDKROOT}/bin"
add_path "${ALTERAOCLSDKROOT}/${OS}/bin"
add_path "${ALTERAOCLSDKROOT}/host/${OS}/bin"
add_path "${ALTERA}/modelsim_ae/bin"
add_path "${ALTERA}/modelsim_ae/${OS_MODELSIM}aloem"

add_ldpath "${ALTERAOCLSDKROOT}/${OS}/lib"
add_ldpath "${ALTERAOCLSDKROOT}/host/${OS}/lib"
add_ldpath "${AOCL_BOARD_PACKAGE_ROOT}/${OS}/lib"

echo "export ALTERA_SETUP_SH_VER='${V}';"
echo "export ALTERA_SETUP_SH_BSP='${BOARD}';"
echo "export PATH='${PATH}';"
echo "export LD_LIBRARY_PATH='${LD_LIBRARY_PATH}';"
echo "export QUARTUS_ROOTDIR='${QUARTUS_ROOTDIR}';"
echo "export ALTERAOCLSDKROOT='${ALTERAOCLSDKROOT}';"
echo "export SOPC_KIT_NIOS2='${SOPC_KIT_NIOS2}';"
echo "export AOCL_BOARD_PACKAGE_ROOT='${AOCL_BOARD_PACKAGE_ROOT}';"
echo "export QUARTUS_64BIT='${QUARTUS_64BIT}';"
echo "export LM_LICENSE_FILE='${LM_LICENSE_FILE}';"
echo "echo \">> Quartus Prime (${1}, ${V}) and BSP ${BOARD} are loaded.\";"
echo "echo \">>     aoc = \$(readlink -f \$(which aoc))\";"
echo "echo \">> quartus = \$(readlink -f \$(which quartus))\";"
echo "echo \">>    vsim = \$(readlink -f \$(which vsim))\";"
