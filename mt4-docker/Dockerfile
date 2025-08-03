FROM scottyhardy/docker-wine:stable

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    WINEDEBUG=-all \
    LANG=en_US.UTF-8 \
    WINEARCH=win32 \
    WINEPREFIX=/home/wineuser/.wine32 \
    XDG_RUNTIME_DIR=/tmp/runtime-wineuser

USER root

# ✅ สร้าง runtime dir
RUN mkdir -p /tmp/runtime-wineuser && chmod 700 /tmp/runtime-wineuser

# ✅ ติดตั้ง dependencies
RUN apt-get update && apt-get install -y \
    xvfb x11vnc websockify supervisor wget unzip winetricks libvulkan1 cabextract \
    && rm -rf /var/lib/apt/lists/*

# ✅ เตรียม Wine Prefix แบบ headless
RUN Xvfb :99 -screen 0 1024x768x24 & \
    sleep 3 && \
    export DISPLAY=:99 && \
    wineboot --init && \
    wineserver -w && \
    winetricks --unattended comctl32 vcrun6 corefonts vcrun2005 vcrun2008 vcrun2010

# ✅ สร้าง user ถ้าไม่มี
RUN id -u wineuser &>/dev/null || useradd -m -u 1000 -s /bin/bash wineuser
RUN chown -R wineuser:wineuser /home/wineuser

USER wineuser
WORKDIR /home/wineuser

# ✅ ดาวน์โหลดและติดตั้ง MT4 แบบ Silent
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe -O mt4setup.exe \
    && xvfb-run wine mt4setup.exe /silent || true

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
