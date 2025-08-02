FROM ubuntu:20.04

# ... ติดตั้ง dependencies ตามเดิม ...

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y software-properties-common wget gnupg2

RUN wget -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

RUN echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ focal main" | tee /etc/apt/sources.list.d/winehq.list

RUN apt-get update && apt-get install -y --install-recommends winehq-stable xvfb wget unzip cabextract winbind libwine:i386

RUN rm -rf /var/lib/apt/lists/*

# ดาวน์โหลด MT4 installer
RUN mkdir -p /root/mt4 && \
    wget -O /root/mt4/mt4setup.exe "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe"

# ติดตั้ง MT4 แบบ silent ภายใต้ root user
RUN wine /root/mt4/mt4setup.exe /silent && rm /root/mt4/mt4setup.exe

# เตรียมโฟลเดอร์ Experts และ Logs
RUN mkdir -p "/root/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Experts" \
    && mkdir -p "/root/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Logs"

WORKDIR /root/.wine/drive_c/Program\ Files/MetaTrader\ 4/MQL4/Experts/

# คัดลอก EA เข้าโฟลเดอร์ Experts
COPY experts/Safe_Martingale_Pro_EA.ex4 ./

WORKDIR /root

VOLUME ["/root/config", "/root/logs"]

COPY entrypoint.sh /root/entrypoint.sh

RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
