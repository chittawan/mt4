docker build --platform=linux/amd64 -t mt4-image .

docker run -d 
  -p 8080:8080 \     # สำหรับ noVNC (เว็บ VNC)
  -p 5900:5900 \     # สำหรับ VNC client ทั่วไป (ถ้าต้องการ)
  --name mt4-vnc-container \
  mt4
