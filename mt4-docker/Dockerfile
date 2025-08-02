FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEDEBUG=-all \
    LANG=en_US.UTF-8 \
    DISPLAY=:99

# ติดตั้ง dependency
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common wget gnupg2 \
        xvfb cabextract unzip winbind \
        && rm -rf /var/lib/apt/lists/*

# ติดตั้ง Wine จาก official repository
RUN wget -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ focal main" | tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable libwine:i386 && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get install -y --install-recommends winehq-stable wine32 libwine:i386

# เตรียม Wine prefix
RUN xvfb-run --auto-servernum --server-args="-screen 0 1024x768x16" wineboot --init && \
    sleep 5

WORKDIR /root

# ดาวน์โหลด MT4 installer
RUN mkdir -p /root/mt4 && \
    wget -O /root/mt4/mt4setup.exe "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe"

# ติดตั้ง MT4 แบบ headless
RUN xvfb-run --auto-servernum --server-args="-screen 0 1024x768x16" \
    wine /root/mt4/mt4setup.exe /silent && \
    rm /root/mt4/mt4setup.exe && \
    ls -l "/root/.wine/drive_c/Program Files/MetaTrader 4/" || (echo "❌ MT4 install failed!" && exit 1)


# สร้างโฟลเดอร์ Experts และ Logs
RUN mkdir -p "/root/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Experts" \
    && mkdir -p "/root/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Logs"

# คัดลอก EA เข้าโฟลเดอร์ Experts
WORKDIR "/root/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Experts/"
COPY experts/Safe_Martingale_Pro_EA.ex4 ./

# กลับไปที่ root
WORKDIR /root

# Volume สำหรับ config และ logs
VOLUME ["/root/config", "/root/logs"]

# คัดลอก entrypoint และให้สิทธิ์รัน
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
