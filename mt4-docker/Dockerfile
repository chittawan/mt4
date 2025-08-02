FROM scottyhardy/docker-wine:stable

ENV DEBIAN_FRONTEND=noninteractive \
    WINEDEBUG=-all \
    DISPLAY=:99 \
    LANG=en_US.UTF-8

WORKDIR /root

# ติดตั้ง Xvfb และ winetricks
RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb winetricks wget unzip cabextract && \
    rm -rf /var/lib/apt/lists/*

# เตรียม Wine prefix
RUN wineboot --init && sleep 5

# ติดตั้ง corefonts เพื่อให้ MT4 UI ปกติ
RUN xvfb-run --auto-servernum --server-args="-screen 0 1024x768x16" \
    winetricks -q corefonts

# ดาวน์โหลด MT4 installer
RUN mkdir -p /root/mt4 && \
    wget -O /root/mt4/mt4setup.exe "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe"

# ติดตั้ง MT4 แบบ headless
RUN xvfb-run --auto-servernum --server-args="-screen 0 1024x768x16" \
    wine /root/mt4/mt4setup.exe /silent && \
    rm /root/mt4/mt4setup.exe && \
    ls -l "/root/.wine/drive_c/Program Files/MetaTrader 4/" || (echo "❌ MT4 install failed!" && exit 1)

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
