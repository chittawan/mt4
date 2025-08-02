FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEDEBUG=-all \
    DISPLAY=:0 \
    LANG=en_US.UTF-8

RUN dpkg --add-architecture i386

RUN apt-get update

RUN apt-get install -y software-properties-common wget gnupg2

RUN wget -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

RUN echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ focal main" | tee /etc/apt/sources.list.d/winehq.list

RUN apt-get update

RUN apt-get install -y --install-recommends winehq-stable xvfb wget unzip cabextract winbind libwine:i386

RUN rm -rf /var/lib/apt/lists/*

# ดาวน์โหลด MT4 installer ด้วย wget แทน COPY
RUN mkdir -p /home/trader/mt4 && \
    wget -O /home/trader/mt4/mt4setup.exe "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe"

# ติดตั้ง MT4 แบบ silent และลบ installer
RUN wine /home/trader/mt4/mt4setup.exe /silent && rm /home/trader/mt4/mt4setup.exe

# เตรียมโฟลเดอร์ MQL4 และ Logs
RUN mkdir -p "/home/trader/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Experts" \
    && mkdir -p "/home/trader/.wine/drive_c/Program Files/MetaTrader 4/MQL4/Logs"

WORKDIR /home/trader/.wine/drive_c/Program\ Files/MetaTrader\ 4/MQL4/Experts/

# คัดลอก EA เข้าโฟลเดอร์ Experts
COPY experts/Safe_Martingale_Pro_EA.ex4 ./

WORKDIR /home/trader

VOLUME ["/home/trader/config", "/home/trader/logs"]

COPY entrypoint.sh /home/trader/entrypoint.sh
RUN chmod +x /home/trader/entrypoint.sh

ENTRYPOINT ["/home/trader/entrypoint.sh"]




