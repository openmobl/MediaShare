#!/bin/bash

echo "********************************"
echo "********* Building IPK *********"
echo "********************************"

STAGING="staging/"
STAGING_APP="staging/app/"
STAGING_PKG="staging/package/"
STAGING_SRVC="staging/service/"
#METRIX="MetrixLibrary/"

#if [ ! -d ${METRIX} ]; then
#    echo "Please download the Metrix libraries and extract into ./MetrixLibrary"
#    exit
#fi;

echo "**** Cleaning MediaShare"

rm com.openmobl.app.mediashare_*

if [ ! -d ${STAGING} ]; then
    mkdir ${STAGING}
    mkdir ${STAGING_APP}
    mkdir ${STAGING_PKG}
    mkdir ${STAGING_SRVC}
else
    rm -rf ${STAGING}
    mkdir ${STAGING}
    mkdir ${STAGING_APP}
    mkdir ${STAGING_PKG}
    mkdir ${STAGING_SRVC}
fi;

echo "**** Staging MediaShare"

cp -R app/ ${STAGING_APP}
cp -R package/ ${STAGING_PKG}
cp -R service/ ${STAGING_SRVC}

cp libs/lib/libixml.so.2.0.4 ${STAGING_APP}libixml.so.2
cp libs/lib/libthreadutil.so.2.1.1 ${STAGING_APP}libthreadutil.so.2
cp libs/lib/libupnp.so.3.0.0 ${STAGING_APP}libupnp.so.3
cp ushare-1.1a/src/ushare ${STAGING_APP}ushare

#echo "**** Staging Metrix"

#cp -R ${METRIX}images ${STAGING}
#cp ${METRIX}app/models/metrix.js ${STAGING}app/models/
#cp ${METRIX}app/models/metrixCore.js ${STAGING}app/models/
#cp ${METRIX}app/models/asyncWrappers.js ${STAGING}app/models/
#cp -R ${METRIX}app/views/metrix ${STAGING}app/views/

echo "**** Generating Build Information"

./gen_build.sh ${STAGING_APP}

echo "**** Packaging MediaShare"

palm-package ${STAGING_APP} ${STAGING_SRVC} ${STAGING_PKG}

echo "**** Installing MediaShare"

palm-install com.openmobl.app.mediashare_*

