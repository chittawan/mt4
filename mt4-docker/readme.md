docker build --platform=linux/amd64 -t mt4-image .

docker run -d 
  -p 8080:8080 \     # สำหรับ noVNC (เว็บ VNC)
  -p 5900:5900 \     # สำหรับ VNC client ทั่วไป (ถ้าต้องการ)
  --name mt4-vnc-container \
  mt4

docker run -d -p 8080:8080  -p 5900:5900 -p 6080:6080 --name mt4-vnc-container mq4


docker run -d --rm \
    --cap-add=SYS_PTRACE \
    -v /volume1/docker/mq4-volume/mt4:/home/winer/.wine/drive_c/mt4 \
    nevmerzhitsky/headless-metatrader4

docker run -d --name mt4-headless --rm     --cap-add=SYS_PTRACE  -p 5900:5900 -p 6080:6080  
-v /volume1/docker/mq4-volume/mt4:/home/winer/.wine/drive_c/mt4     
-v /volume1/docker/mq4-volume/MetaQuotes:/home/winer/.wine/drive_c/users/winer/Application\ Data/MetaQuotes     
nevmerzhitsky/headless-metatrader4

-v "/volume1/docker/mq4-volume/MetaQuotes:/home/winer/.wine/drive_c/users/winer/Application Data/MetaQuotes" \
  
/home/winer/.wine/drive_c/users/winer/Application\ Data/MetaQuotes

docker exec <container_id> /docker/screenshot.sh
docker exec mt4-web-portal-1 /docker/screenshot.sh

docker cp mt4-web-portal-1:/docker/20250804_023934.png /volume1/docker/


docker exec -it mt4-web-portal-1 bash

Xvfb :0 -screen 0 1024x768x24 & x11vnc -display :0 -bg -nopw -forever -rfbport 5900 & /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &  wine terminal /portable startup.ini &
