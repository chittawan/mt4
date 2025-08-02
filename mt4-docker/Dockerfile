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
    wget -O /root/mt4/mt4.zip "https://codewalk.myds.me:5001/d/s/14QN4ofZXk4e06HBxtImrgyd3FooqLKE/webapi/entry.cgi/SYNO.SynologyDrive.Files/Meta%20Trader%204.zip?api=SYNO.SynologyDrive.Files&method=download&version=2&files=%5B%22id%3A899205825556429413%22%5D&force_download=true&json_error=true&download_type=%22download%22&c2_offload=%22allow%22&_dc=1754150950328&sharing_token=%22ibty1NOJfkOKt5ygbYHFEq3YF3VSG8n8rjkN1onDjgq_O8aOcw2orYIK2gRDB4fEwcSD9QWAkYOt9pfn4PZtwiZ52Pgk_RY8Ri43QxSSr69p0xv3CRHro7vWXDxks.59xPyawfg8epTfFuRr60FjHluwBipT2qIygVyQh0k0KmwqqP8dT1geAJajEvOEmBtj8sSnJhhzr0Wj1wNNkN..23PGgP8iXNjUgSKUpIUNr8DYs0edNyWRM5st%22&SynoToken=cWdL2r39D8Xqc" && \
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
