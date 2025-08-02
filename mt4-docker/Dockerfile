FROM scottyhardy/docker-wine:stable

ENV WINEDEBUG=-all \
    LANG=en_US.UTF-8 \
    DISPLAY=:0

# ติดตั้งเครื่องมือพื้นฐาน
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# สร้างโฟลเดอร์สำหรับ MT4 และ Experts
WORKDIR /root

# ดาวน์โหลด MT4 Portable (ZIP version)
RUN mkdir -p /root/mt4 && \
    wget -O /root/mt4/mt4.zip "https://files.metaquotes.net/metaquotes.software.corp/mt4/mt4.zip" && \
    unzip /root/mt4/mt4.zip -d /root/mt4 && \
    rm /root/mt4/mt4.zip

# เตรียมโฟลเดอร์ Experts
RUN mkdir -p "/root/mt4/MQL4/Experts" && \
    mkdir -p "/root/mt4/MQL4/Logs"

# คัดลอก EA เข้า Experts
COPY experts/Safe_Martingale_Pro_EA.ex4 "/root/mt4/MQL4/Experts/"

# Volume สำหรับ config และ logs
VOLUME ["/root/config", "/root/logs"]

# คัดลอก entrypoint script
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

WORKDIR /root/mt4

ENTRYPOINT ["/root/entrypoint.sh"]
