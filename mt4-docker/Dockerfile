FROM scottyhardy/docker-wine:stable

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    WINEDEBUG=-all \
    LANG=en_US.UTF-8 \
    WINEARCH=win32 \
    WINEPREFIX=/home/wineuser/.wine32 \
    XDG_RUNTIME_DIR=/tmp/runtime-wineuser

USER root
RUN mkdir -p /tmp/runtime-wineuser && chmod 700 /tmp/runtime-wineuser

# ติดตั้ง dependencies
RUN apt-get update && apt-get install -y \
    xvfb x11vnc websockify supervisor wget unzip winetricks cabextract \
    && rm -rf /var/lib/apt/lists/*

# ✅ เปลี่ยนกลับไปใช้ user wineuser (มีอยู่แล้ว)
USER wineuser

# ✅ เตรียม Wine Prefix และติดตั้ง dependencies
RUN Xvfb :99 -screen 0 1024x768x24 & \
    sleep 5 && \
    DISPLAY=:99 wineboot --init && \
    wineserver -w && \
    DISPLAY=:99 winetricks --unattended comctl32 vcrun6 corefonts vcrun2005 vcrun2008 vcrun2010

# ✅ ดาวน์โหลดและติดตั้ง MT4 แบบ Silent
WORKDIR /home/wineuser
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe -O mt4setup.exe \
    && xvfb-run --auto-servernum wine mt4setup.exe /silent || true

# ✅ ตั้งรหัสผ่าน VNC
RUN mkdir -p /home/wineuser/.vnc && \
    x11vnc -storepasswd wineuser /home/wineuser/.vnc/passwd

# ✅ กลับเป็น root ติดตั้ง noVNC
USER root
RUN mkdir -p /opt/novnc && \
    wget https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.zip && \
    unzip v1.4.0.zip && \
    mv noVNC-1.4.0/* /opt/novnc && \
    rm -rf v1.4.0.zip noVNC-1.4.0

# ✅ คัดลอกไฟล์ Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 5900

CMD ["/usr/bin/supervisord"]
