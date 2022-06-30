#!/bin/bash

set -e

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
GREEN_YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

declare fePath
declare -a searchingPaths=(
	"/usr/local/lib/"
	"$PWD"
)

function info () { echo -e "${GREEN_COLOR}INFO: $1${NO_COLOR}";}
function warn () { echo -e "${GREEN_YELLOW}WARN: $1${NO_COLOR}";}
function error () { echo -e "${RED_COLOR}ERROR: $1${NO_COLOR}"; if [ "$2" != "false" ]; then exit 1;fi; }

function checkRequirement () {
	if [ -z "$(command -v "$1")" ]; then
		error "'$1' 가 설치되어 있지 않습니다."
	fi
}

checkRequirement "wget"

for searchingPath in "${searchingPaths[@]}"; do
	if [ -n "$fePath" ]; then
		break
	fi

	info "'$searchingPath' 에서 hass_frontend 디렉토리 찾는중..."

	findPaths=($(find $searchingPath -name hass_frontend -type d))
	findCnt=${#findPaths[@]}

	if [ $findCnt -gt 0 ]; then
		echo "* 작업 대상 경로 목록"
		echo -e "    0) 경로가 없음."
		for (( n = 0; n < $findCnt; n++ )); do
			echo -e "    $(expr $n + 1)) ${findPaths[$n]}"
		done

		while true; do
			read -p "작업할 경로 번호를 입력하세요: " num
			if [ $num -eq 0 ]; then
				break
			elif [ $num -gt $findCnt ]; then
				continue
			else
				fePath=${findPaths[$(($num - 1))]}
				break
			fi
		done
	fi
done


if [ -n "$fePath" ]; then
	info "'$fePath 에서 패치 진행..."
else
	error "패치를 수행할 hass_frontend 경로를 찾지 못하였습니다."
fi

cd $fePath

cur_dir=${PWD##*/}


if [ $cur_dir != 'hass_frontend' ]; then
	error "작업 경로가 올바르지 않습니다. 'hass_frontend'!! ('$cur_dir')"
fi

declare ES5_TARGET_FILES=($(grep -nrl 'basemaps.cartocdn.com' ./frontend_es5/*.js))

info "frontend_es5/ 디렉토리 패치중.."
for targetFile in "${ES5_TARGET_FILES[@]}"; do
	echo -e "  patch file : $targetFile"
	cp $targetFile ${targetFile}.backup
        sed -i 's/\"https:\/\/{s}.basemaps.cartocdn.com\/\".*maxZoom:20/"https:\/\/map.pstatic.net\/nrb\/styles\/"\.concat\(t\?"satellite":"basic","\/\{z\}\/\{x\}\/\{y\}\.png\?mt\=bg\.ol\.ts\.ar\.lko"\),\{minZoom:6,maxZoom:19,continuousWorld:\!0/g' $targetFile
	gzip -f -k $targetFile
done


if [ ${#ES5_TARGET_FILES[@]} -eq 0 ]; then
	warn "frontend_es5/ 디렉토리에 패치할 파일이 없습니다."
fi


declare LATEST_TARGET_FILES=($(grep -nrl 'basemaps.cartocdn.com' ./frontend_latest/*.js))

info "frontend_latest/ 디렉토리 패치중.."
for targetFile in "${LATEST_TARGET_FILES[@]}"; do
	echo -e "  patch file : $targetFile"
	cp $targetFile ${targetFile}.backup
	sed -i 's/`https:\/\/{s}.basemaps.cartocdn.com\/.*maxZoom:20/`https:\/\/map.pstatic.net\/nrb\/styles\/\$\{t\?"satellite":"basic"\}\/\{z\}\/\{x\}\/\{y\}.png\?mt\=bg\.ol\.ts\.ar\.lko\`,\{minZoom:6,maxZoom:19,continuousWorld:\!0/g' $targetFile
	gzip -f -k $targetFile
done


if [ ${#LATEST_TARGET_FILES[@]} -eq 0 ]; then
	warn "frontend_latest/ 디렉토리에 패치할 파일이 없습니다."
fi

info "작업 완료!!"

