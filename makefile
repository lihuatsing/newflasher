ARMCC=/home/savan/Desktop/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-gcc
ARMSTRIP=/home/savan/Desktop/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-strip

ARMCC64=/home/savan/Desktop/gcc-linaro-5.3.1-2016.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc
ARMSTRIP64=/home/savan/Desktop/gcc-linaro-5.3.1-2016.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-strip

NDK_BUILD := NDK_PROJECT_PATH=. /root/ndk/android-ndk-r21d/ndk-build NDK_APPLICATION_MK=./Application.mk

CCWIN=i686-w64-mingw32-gcc
CCWINSTRIP=i686-w64-mingw32-strip
WINDRES=i686-w64-mingw32-windres

OS := $(shell uname)
VERSION := $(shell sed 's/^.*VERSION //' version.h)

CC=gcc
STRIP=strip
INSTALL=install

DESTDIR=
LIBS=

CFLAGS?=-Wall -g -O2
ifeq ($(OS),Darwin)
CFLAGS+= -I/usr/local/include/libusb-1.0
LIBS+=-lusb-1.0
endif
CROSS_CFLAGS=${CFLAGS} -I include -I zlib-1.3.1 -L zlib-1.3.1 -I expat-2.2.9/lib -L expat-2.2.9/lib/.libs

.PHONY: default
default: newflasher

.PHONY: cross
cross: newflasher.exe newflasher.x64 newflasher.i386 newflasher.arm32 newflasher.arm64 newflasher.arm64_pie

.PHONY: libs
libs:
	@mkdir -p include
	@test -d zlib-1.3.1 && echo "" || ([ -f zlib-1.3.1.tar.gz ] || wget https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz;tar xzf zlib-1.3.1.tar.gz)
	@test -d expat-2.2.9 && echo "" || ([ -f expat-2.2.9.tar.gz ] || wget https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz;tar xzf expat-2.2.9.tar.gz)

newflasher: newflasher.c version.h
	${CC} ${CFLAGS} $< -o $@ -lz -lexpat ${LIBS}

newflasher.exe: libs newflasher.c version.h
	@cd zlib-1.3.1 && CC=${CCWIN} ./configure --static && make clean && make
	@cd expat-2.2.9 && CC="${CCWIN} -fPIC" ./configure --enable-static --disable-shared --host=i686-w64-mingw32 && make clean && make
	@test -f include/GordonGate.h && echo "" || wget https://software.sonymobile.com/drivers/installers/latest/Sony_Mobile_Software_Update_Drivers_x64_Setup.msi -O GordonGate
	@test -f include/GordonGate.h && echo "" || xxd --include GordonGate > include/GordonGate.h
	@rm -rf GordonGate
