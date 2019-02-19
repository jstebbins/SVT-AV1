#!/bin/bash
#
# Copyright(c) 2019 Intel Corporation
# SPDX - License - Identifier: BSD - 2 - Clause - Patent
#

# Uncomment to show command lines as they are executed
set -x

function clean {
    rm -R -f debug
    rm -R -f release
    rm -R -f ../../Bin/Debug
    rm -R -f ../../Bin/Release
}

function build {
    build_type=$1
    lowercase_build_type=$(echo ${build_type} | tr '[:upper:]' '[:lower:]')
    mkdir -p $lowercase_build_type
    mkdir -p ../../Bin/$build_type
    cd $lowercase_build_type

    cmake_env="-DENABLE_SHARED=${enable_shared}"
    cmake_env+=" -DCMAKE_BUILD_TYPE=${build_type}"
    cmake_env+=" -DCMAKE_C_COMPILER=${cross_prefix}gcc"
    cmake_env+=" -DCMAKE_CXX_COMPILER=${cross_prefix}g++"
    cmake_env+=" -DCMAKE_INSTALL_PREFIX=${install_prefix}"
    cmake_env+=" -DCMAKE_ASM_NASM_COMPILER=yasm"

    if [ "x${target_system}" != "x" ] ; then
        cmake_env+=" -DCMAKE_SYSTEM_NAME=${target_system}"
        if [ "${target_system}" == "Windows" ] ; then
            cmake_env+=" -DCMAKE_RC_COMPILER=${cross_prefix}windres"
        fi
    fi
    cmake ../../.. ${cmake_env}

    # Compile the Library
    make -j $(nproc)
    cd ..
}

# Defines
cross_prefix="x86_64-w64-mingw32-"
target_system="Windows"
install_prefix="/usr/local"
enable_shared=ON
build_command=all

usage()
{
    cat <<EOF
Usage: $0 [ -p install_prefix ] [ -c cross_prefix ] [ -s system ] [ -x ] [ -h ] command
Options:
    -p install_prefix - Installation directory prefix (default /usr/local)
    -c cross_prefix   - cross-tools prefix (default "x86_64-w64-mingw32-")
    -s system         - Target system (default "Windows")
    -x                - Disable building shared library (default enabled)
    -h                - Show this message
    command           - clean, all, release, debug (default all)
EOF
}

while getopts "p:c:s:xh" opt; do
    case ${opt} in
        p)
            install_prefix=${OPTARG}
            ;;
        c)
            cross_prefix=${OPTARG}
            ;;
        s)
            target_system=${OPTARG}
            ;;
        x)
            enable_shared=OFF
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))
if [ $# -eq 1 ]; then
    build_command=$1
elif [ $# != 0 ]; then
    usage
    exit 1
fi

cd $(dirname $(realpath $0))

if [ "${build_command}" = "clean" ]; then
    clean
elif [ "${build_command}" = "debug" ]; then
    build Debug
elif [ "${build_command}" = "release" ]; then
    build Release
elif [ "${build_command}" = "all" ]; then
    build Debug
    build Release
else
    usage
    exit 1
fi

exit
