FROM scottyhardy/docker-wine:stable

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    WINEDEBUG=-all \
    LANG=en_US.UTF-8 \
    WINEARCH=win32 \
    WINEPREFIX=/home/wineuser/.wine32 \
    XDG_RUNTIME_DIR=/tmp/runtime-wineuser

# ✅ สร้าง runtime dir และติดตั้ง dependencies
USER root
RUN mkdir -p /tmp/runtime-wineuser && chmod 700 /tmp/runtime-wineuser

RUN apt-get update && apt-get install -y \
    xvfb x11vnc websockify supervisor wget unzip winetricks cabextract \
    && rm -rf /var/lib/apt/lists/*

# ✅ สร้าง user wineuser ถ้าไม่มี
RUN id -u wineuser &>/dev/null || useradd -m -u 1000 -s /bin/bash wineuser
# ✅ สร้าง user wineuser และ home directory
RUN useradd -m -u 1000 -s /bin/bash wineuser && \
    mkdir -p /home/wineuser/.wine32 && \
    chown -R wineuser:wineuser /home/wineuser

# ✅ เตรียม Wine Prefix และติดตั้งไลบรารีที่ต้องใช้
USER wineuser
RUN Xvfb :99 -screen 0 1024x768x24 & \
    sleep 5 && \
    DISPLAY=:99 WINEARCH=win32 WINEPREFIX=/home/wineuser/.wine32 wineboot --init && \
    wineserver -w && \
    DISPLAY=:99 WINEPREFIX=/home/wineuser/.wine32 winetricks --unattended comctl32 vcrun6 corefonts vcrun2005 vcrun2008 vcrun2010

# ✅ ดาวน์โหลดและติดตั้ง MT4 แบบ Silent
WORKDIR /home/wineuser
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe -O mt4setup.exe \
    && xvfb-run --auto-servernum wine mt4setup.exe /silent || true

# ✅ ตั้งรหัสผ่าน VNC
RUN mkdir -p /home/wineuser/.vnc && \
    x11vnc -storepasswd wineuser /home/wineuser/.vnc/passwd

# ✅ ติดตั้ง noVNC
RUN mkdir -p /opt/novnc && \
    wget https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.zip && \
    unzip v1.4.0.zip && \
    mv noVNC-1.4.0/* /opt/novnc && \
    rm -rf v1.4.0.zip noVNC-1.4.0

USER root

# ✅ คัดลอกไฟล์ Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 5900

CMD ["/usr/bin/supervisord"]
