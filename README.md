# ha_map_patch

homeassistant 의 지도를 한국지도로 변경

## docker
도커 컨테이너 내부로 진입하여 아래 명령어 수행


1. 컨테이너명 찾기

```shell
$ docker ps --format "table {{.Image}}\t{{.Names}}" | grep home-assistant            
ghcr.io/home-assistant/home-assistant:stable          homeassistant
```

여기서 컨테이너명은 homeassistant.


2. 컨테이너 진입
```shell
$ docker exec -it homeassistant bash
```


3. 커맨드 수행
```shell
$ bash -c "$(wget -O - 'https://raw.githubusercontent.com/nimusis/ha_map_patch/main/ha_map_patch.sh')" 
```

## 도커 외의 시스템

현재 위치와 `/usr/local/lib/` 에서 `hass_frontend` 디렉토리를 찾아서 패치 수행을 함. 


```shell
$ bash -c "$(wget -O - 'https://raw.githubusercontent.com/nimusis/ha_map_patch/main/ha_map_patch.sh')" 
```

