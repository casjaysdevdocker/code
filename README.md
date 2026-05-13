## 👋 Welcome to code 🚀  

code README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update code
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/code/code/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/code/rootfs"
git clone "https://github.com/dockermgr/code" "$HOME/.local/share/CasjaysDev/dockermgr/code"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/code/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-code-latest \
--hostname code \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/code:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/code
    container_name: casjaysdevdocker-code
    environment:
      - TZ=America/New_York
      - HOSTNAME=code
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/code/code/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/code/code/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/code
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/code" "$HOME/Projects/github/casjaysdevdocker/code"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/code"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
