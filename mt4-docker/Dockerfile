FROM nevmerzhitsky/headless-metatrader4:latest
ENV USER=winer
ENV MT4DIR="/home/$USER/.wine/drive_c/metaquotes"
EXPOSE 8080 5900 6080
CMD ["/docker/run_mt.sh"]