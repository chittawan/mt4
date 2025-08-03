FROM scottyhardy/docker-wine:stable

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    WINEDEBUG=-all \
    LANG=en_US.UTF-8 \
    WINEARCH=win32 \
    WINEPREFIX=/home/wineuser/.wine32

USER root

# ติดตั้ง dependencies
RUN apt-get update && apt-get install -y \
    xvfb x11vnc websockify supervisor wget unzip winetricks libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

# สร้างรหัสผ่าน VNC
RUN mkdir -p /home/wineuser/.vnc && \
    x11vnc -storepasswd wineuser /home/wineuser/.vnc/passwd && \
    chown -R wineuser:wineuser /home/wineuser/.vnc

USER wineuser
WORKDIR /home/wineuser

# สร้าง Wine Prefix 32-bit และติดตั้ง runtime
RUN xvfb-run winecfg || true \
    && xvfb-run winetricks --unattended comctl32 vcrun6 corefonts vcrun2005 vcrun2008 vcrun2010

# ดาวน์โหลดและติดตั้ง MT4 แบบ silent
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe -O mt4setup.exe \
    && xvfb-run wine mt4setup.exe /silent

# ติดตั้ง noVNC
RUN mkdir -p /opt/novnc && \
    wget https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.zip && \
    unzip v1.4.0.zip && \
    mv noVNC-1.4.0/* /opt/novnc && \
    rm -rf v1.4.0.zip noVNC-1.4.0

USER root

# คัดลอกไฟล์ Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 5900

CMD ["/usr/bin/supervisord"]
