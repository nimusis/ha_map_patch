#!/bin/bash

set -e

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
GREEN_YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

function info () { echo -e "${GREEN_COLOR}INFO: $1${NO_COLOR}";}
function warn () { echo -e "${GREEN_YELLOW}WARN: $1${NO_COLOR}";}
function error () { echo -e "${RED_COLOR}ERROR: $1${NO_COLOR}"; if [ "$2" != "false" ]; then exit 1;fi; }

function checkRequirement () {
        if [ -z "$(command -v "$1")" ]; then
                error "'$1' is not installed"
        fi
}

checkRequirement "wget"

BASE_PATH=./

case "${1:-''}" in
    'docker')
        BASE_PATH=`find /usr -name hass_frontend -type d`
        info "find hass_frontend directory. ('$BASE_PATH')"
        ;;
esac

cd $BASE_PATH

cur_dir=${PWD##*/}


if [ $cur_dir != 'hass_frontend' ]; then
        error "current directory is not 'hass_frontend'!! ('$cur_dir')"
fi

declare ES5_TARGET_FILES=($(grep -nrl 'basemaps.cartocdn.com' ./frontend_es5/*.js))

for targetFile in "${ES5_TARGET_FILES[@]}"; do
        info "patch file : '$targetFile'"
        cp $targetFile ${targetFile}.backup
        sed -i 's/\"https:\/\/{s}.basemaps.cartocdn.com\/\".*maxZoom:20/"https:\/\/map.pstatic.net\/nrb\/styles\/"\.concat\(t\?"satellite":"basic","\/\{z\}\/\{x\}\/\{y\}\.png\?mt\=bg\.ol\.ts\.ar\.lko"\),\{minZoom:6,maxZoom:19,continuousWorld:\!0/g' $targetFile
        gzip -f -k $targetFile
done


if [ ${#ES5_TARGET_FILES[@]} -eq 0 ]; then
        warn "nothing to patch on frontend_es5/"
fi


declare LATEST_TARGET_FILES=($(grep -nrl 'basemaps.cartocdn.com' ./frontend_latest/*.js))

for targetFile in "${LATEST_TARGET_FILES[@]}"; do
        info "patch file : '$targetFile'"
        cp $targetFile ${targetFile}.backup
        sed -i 's/`https:\/\/{s}.basemaps.cartocdn.com\/.*maxZoom:20/`https:\/\/map.pstatic.net\/nrb\/styles\/\$\{t\?"satellite":"basic"\}\/\{z\}\/\{x\}\/\{y\}.png\?mt\=bg\.ol\.ts\.ar\.lko\`,\{minZoom:6,maxZoom:19,continuousWorld:\!0/g' $targetFile
        gzip -f -k $targetFile
done

if [ ${#LATEST_TARGET_FILES[@]} -eq 0 ]; then
        warn "nothing to patch on frontend_latest/"
fi

info "Success!!"
