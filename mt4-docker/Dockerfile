FROM nevmerzhitsky/headless-metatrader4:latest
ENV USER=winer
ENV MT4DIR="/home/$USER/.wine/drive_c/users/$USER/Application Data/MetaQuotes"

RUN ln -s "$MT4DIR" /metaquotes

EXPOSE 8080 5900 6080
CMD ["/docker/run_mt.sh"]