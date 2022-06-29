#!/bin/bash

BASE_PATH=./

case "${1:-''}" in
    'docker')
        BASE_PATH=`find /usr -name hass_frontend -type d`
	echo -e "find hass_frontend directory path. ($BASE_PATH)\n"
        ;;  
esac

cd $BASE_PATH

result=${PWD##*/}
result=${result:-/}

echo -e "current dir = $result\n"

if [ $result != 'hass_frontend' ]
then
	echo "current directory is not 'hass_frontend'!!"
	exit 1
fi

ES5_TARGET_FILES=`grep -nrl 'basemaps.cartocdn.com' ./frontend_es5/*.js`

for i in $ES5_TARGET_FILES; do
        echo -e "patch file : $i"
	cp $i ${i}.backup
	sed -i 's/\"https:\/\/{s}.basemaps.cartocdn.com\/\".*maxZoom:20/"https:\/\/map.pstatic.net\/nrb\/styles\/"\.concat\(t\?"satellite":"basic","\/\{z\}\/\{x\}\/\{y\}\.png\?mt\=bg\.ol\.ts\.ar\.lko"\),\{minZoom:6,maxZoom:19,continuousWorld:\!0/g' $i
	gzip -f -k $i
done


LATEST_TARGET_FILES=`grep -nrl 'basemaps.cartocdn.com' ./frontend_latest/*.js`

for i in $LATEST_TARGET_FILES; do
        echo -e "patch file : $i"
	cp $i ${i}.backup
	sed -i 's/`https:\/\/{s}.basemaps.cartocdn.com\/.*maxZoom:20/`https:\/\/map.pstatic.net\/nrb\/styles\/\$\{t\?"satellite":"basic"\}\/\{z\}\/\{x\}\/\{y\}.png\?mt\=bg\.ol\.ts\.ar\.lko\`,\{minZoom:6,maxZoom:19,continuousWorld:\!0/g' $i
	gzip -f -k $i
done

echo "success!!"

