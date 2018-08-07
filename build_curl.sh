#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./build_curl.sh tool_chain_path install_path!"
    echo "Example: ./build_curl.sh /usr/local/arm-linux /Desktop/eric/logger/build/moxa-ia240/curl"
    exit
fi

if [ ! -f "configure" ]; then
	./buildconf
fi

export PATH="$PATH:$1/bin"

tool_chain_path=${1%/}
install_path=$2/../

# linux architecture
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

export CROSS_COMPILE=$ARCH
export CPPFLAGS="-I$tool_chain_path/include -I$tool_chain_path/include"
export LDFLAGS="-L$tool_chain_path/lib -L$tool_chain_path/lib"

make distclean

if [ "$CROSS_COMPILE" == "" ]; then
	export AR=ar
	export AS=as
	export CC=gcc
	export LD=ld
	export NM=nm
	./configure --prefix=$2 --disable-shared --enable-static --with-ssl=$install_path/lib --with-zlib=$install_path/lib
else
	export AR=${CROSS_COMPILE}-ar
	export AS=${CROSS_COMPILE}-as
	export CC=${CROSS_COMPILE}-gcc
	export LD=${CROSS_COMPILE}-ld
	export NM=${CROSS_COMPILE}-nm
	./configure --prefix=$2 --disable-shared --enable-static --target=${CROSS_COMPILE} --host=${CROSS_COMPILE} --build=i586-pc-linux-gnu --with-ssl=$install_path/lib --with-zlib=$install_path/lib
fi
export LIBS="-lssl -lcrypto"

make
make install
