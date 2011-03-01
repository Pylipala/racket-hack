#!/bin/sh
# Script to regenerate libjpeg for iOS from provided source

ARCH=$1
GCC_VERSION="4.2"

ARCH_PREFIX=
PLATFORMROOT=
DEVROOT=
SDKROOT=
OBJC_CFLAGS=
OBJC_LDFLAGS=

case $ARCH in
    i386 | i686)
	echo "Build for iOS simulator"
	ARCH="i386"
	ARCH_PREFIX="i686"
	PLATFORMROOT=/Developer/Platforms/iPhoneSimulator.platform
	DEVROOT=$PLATFORMROOT/Developer
	SDKROOT=$DEVROOT/SDKs/iPhoneSimulator4.3.sdk
	OBJC_CFLAGS="-mmacosx-version-min=10.6 -gdwarf-2"
	OBJC_LDFLAGS="-mmacosx-version-min=10.6";;
    arm | armv7)
	echo "Build for iOS"
	ARCH="armv7"
	ARCH_PREFIX="arm"
	PLATFORMROOT=/Developer/Platforms/iPhoneOS.platform
	DEVROOT=$PLATFORMROOT/Developer
	SDKROOT=$DEVROOT/SDKs/iPhoneOS4.3.sdk
	OBJC_CFLAGS="-mthumb -miphoneos-version-min=4.1"
	OBJC_LDFLAGS="-miphoneos-version-min=4.1";;
    *)
	echo "Build for default"
	ARCH="i386"
	ARCH_PREFIX="i686"
	PLATFORMROOT=/Developer/Platforms/iPhoneSimulator.platform
	DEVROOT=$PLATFORMROOT/Developer
	SDKROOT=$DEVROOT/SDKs/iPhoneSimulator4.3.sdk
	OBJC_CFLAGS="-mmacosx-version-min=10.6 -gdwarf-2"
	OBJC_LDFLAGS="-mmacosx-version-min=10.6";;
    esac

export CPPFLAGS="-I$SDKROOT/usr/include/"
export CFLAGS="$CPPFLAGS -arch $ARCH -pipe -no-cpp-precomp -isysroot $SDKROOT -I$SDKROOT/usr/include -L$SDKROOT/usr/lib/ -O3 $OBJC_CFLAGS"
export CPP="/usr/bin/cpp $CPPFLAGS"
export LDFLAGS="-arch $ARCH -isysroot $SDKROOT -L$SDKROOT/usr/lib/ $OBJC_LDFLAGS"

./configure --enable-shared --enable-static \
CC=$DEVROOT/usr/bin/gcc-$GCC_VERSION LD=$DEVROOT/usr/bin/ld --host=$ARCH_PREFIX-apple-darwin

make

