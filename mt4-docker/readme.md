docker build --platform=linux/amd64 -t mt4-image .

docker run -it --rm mt4-image:latest /bin/bash

docker run -d \
  --name mt4-ea-live \
  --restart always \
  -v $(pwd)/config:/home/trader/config \
  -v $(pwd)/logs:/home/trader/.wine/drive_c/Program\ Files/MetaTrader\ 4/MQL4/Logs \
  mt4-ea-live



docker pull scottyhardy/docker-wine:stable
docker run -it --rm     --name mt4-container     scottyhardy/docker-wine:stable bash

xvfb wget
Xvfb :99 -screen 0 1024x768x16 &
export DISPLAY=:99

echo $DISPLAY


docker run -it --rm \
    --name mt4-container \
    scottyhardy/docker-wine:stable bash
apt-get update && apt-get install -y xvfb wget
Xvfb :99 -screen 0 1024x768x16 &
export DISPLAY=:99


wget -O mt4/mt4setup.exe "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe?utm_source=www.metatrader4.com&utm_campaign=download"

wine /mt4/mt4setup.exe

wine /root/mt4setup.exe /silent
wine mt4setup.exe /auto

/root/.wine/drive_c/Program Files/MetaTrader 4/terminal.exe

wine "/root/.wine/drive_c/Program Files/MetaTrader 4/terminal.exe"
