#!/bin/bash

BUILD_DATE=`date`;
BUILD_NUM=1;
BUILD_VER_MAX=0;
BUILD_VER_MIN=1;
BUILD_VER_FIX=0;
BUILD_VER="${BUILD_VER_MAX}.${BUILD_VER_MIN}.${BUILD_VER_FIX}";

cat appinfo.json | sed s/BUILD_VER/${BUILD_VER}/ > $1/appinfo.json

echo \
"var Build = {\
	\"buildDate\":\"${BUILD_DATE}\",\
	\"buildNum\":\"${BUILD_NUM}\",\
	\"buildVer\": \"${BUILD_VER}\",\
	\"buildMax\": \"${BUILD_VER_MAX}\",\
	\"buildMin\": \"${BUILD_VER_MIN}\",\
	\"buildFix\": \"${BUILD_VER_FIX}\"\
};" > $1/buildinfo.js

