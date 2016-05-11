#!/bin/bash

# Usage
# sudo ./build_gcc.sh

# Setup vars
export TARGET=aarch64-none-elf
export PREFIX=/opt/gnuarm64
export PATH=$PATH:$PREFIX/bin
export JN='-j 8'

export GCCVER=6.1.0
export BINUVER=2.26

rm -rf build-*
rm -rf gcc-*
rm -rf binutils-*

# Get archives
wget http://ftp.gnu.org/gnu/binutils/binutils-$BINUVER.tar.bz2
wget http://ftp.gnu.org/gnu/gcc/gcc-$GCCVER/gcc-$GCCVER.tar.bz2

# Extract archives
bzip2 -dc binutils-$BINUVER.tar.bz2 | tar -xf -
bzip2 -dc gcc-$GCCVER.tar.bz2 | tar -xf -

# Install Build-Essential
apt-get install build-essential libmpfr-dev libgmp3-dev libmpc-dev

# Build binutils
mkdir build-binutils
cd build-binutils
../binutils-$BINUVER/configure --target=$TARGET --prefix=$PREFIX
echo "MAKEINFO = :" >> Makefile
make $JN all
make install

# Build GCC
mkdir ../build-gcc
cd ../build-gcc
../gcc-$GCCVER/configure --target=$TARGET --prefix=$PREFIX --without-headers --with-newlib  --with-gnu-as --with-gnu-ld --enable-languages='c'
make $JN all-gcc
make install-gcc

# Build libgcc.a
make $JN all-target-libgcc CFLAGS_FOR_TARGET="-g -O2"
make install-target-libgcc

# Add aarch64-none-elf to PATH
echo "PATH=$PATH" >> ~/.bashrc