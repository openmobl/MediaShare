#!/bin/bash

THIRDPARTY_PATH=/Users/dkirker/projects/webOS/Muses/libs/
LIBS_PATH=${THIRDPARTY_PATH}/lib/
INCLUDE_PATH=${THIRDPARTY_PATH}/include/

PKG_CONFIG_PATH=/Users/dkirker/projects/webOS/Muses/libs/lib/pkgconfig/
export PKG_CONFIG_PATH

echo "********************************"
echo "******** Building uPNP  ********"
echo "********************************"

# Build libUPnP
cd ./libupnp-1.6.0
./configure --host=arm-none-linux-gnueabi --prefix=${THIRDPARTY_PATH} -exec-prefix=${THIRDPARTY_PATH}
make clean all
make install
cd ../

#echo "********************************"
#echo "******* Building ffmpeg  *******"
#echo "********************************"
#
## Build ffmpeg
#cd ./ffmpeg-0.8.5
#./configure --cross-prefix=arm-none-linux-gnueabi- --prefix=${THIRDPARTY_PATH} --enable-static --enable-shared --enable-cross-compile --enable-avformat --disable-doc
#make clean all
#make install
#cd ../

#echo "********************************"
#echo "******** Building DLNA  ********"
#echo "********************************"
#
## Build libUPnP
#cd ./libdlna-0.2.3
#./configure --cross-prefix=arm-none-linux-gnueabi- --prefix=${THIRDPARTY_PATH} --enable-static --enable-shared --cross-compile
#make clean all
#make install
#cd ../

echo "********************************"
echo "******* Building uShare ********"
echo "********************************"


# Build uShare
cd ./ushare-1.1a
CFLAGS="${CFLAGS} -I../ -I${INCLUDE_PATH}" LDFLAGS="-L${LIBS_PATH}" ./configure --cross-prefix=arm-none-linux-gnueabi- --prefix=${THIRDPARTY_PATH} --with-libupnp-dir=${THIRDPARTY_PATH} --cross-compile --disable-dlna --enable-webos
#--enable-dlna
make clean all
cd ../

echo "********************************"
echo "********* Building IPK *********"
echo "********************************"

STAGING="staging/"
#METRIX="MetrixLibrary/"

#if [ ! -d ${METRIX} ]; then
#    echo "Please download the Metrix libraries and extract into ./MetrixLibrary"
#    exit
#fi;

echo "**** Cleaning MediaShare"

rm com.openmobl.app.mediashare_*

if [ ! -d ${STAGING} ]; then
    mkdir ${STAGING}
else
    rm -rf ${STAGING}
    mkdir ${STAGING}
fi;

echo "**** Staging MediaShare"

cp -R app/ ${STAGING}

cp libs/lib/libixml.so.2.0.4 ${STAGING}libixml.so.2
cp libs/lib/libthreadutil.so.2.1.1 ${STAGING}libthreadutil.so.2
cp libs/lib/libupnp.so.3.0.0 ${STAGING}libupnp.so.3
cp ushare-1.1a/src/ushare ${STAGING}ushare

#echo "**** Staging Metrix"

#cp -R ${METRIX}images ${STAGING}
#cp ${METRIX}app/models/metrix.js ${STAGING}app/models/
#cp ${METRIX}app/models/metrixCore.js ${STAGING}app/models/
#cp ${METRIX}app/models/asyncWrappers.js ${STAGING}app/models/
#cp -R ${METRIX}app/views/metrix ${STAGING}app/views/

echo "**** Generating Build Information"

./gen_build.sh ${STAGING}

echo "**** Packaging MediaShare"

palm-package ${STAGING}

echo "**** Installing MediaShare"

palm-install com.openmobl.app.mediashare_*


