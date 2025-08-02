docker build --platform=linux/amd64 -t mt4-image .

docker run -it --rm mt4-image:latest /bin/bash

docker run -d \
  --name mt4-ea-live \
  --restart always \
  -v $(pwd)/config:/home/trader/config \
  -v $(pwd)/logs:/home/trader/.wine/drive_c/Program\ Files/MetaTrader\ 4/MQL4/Logs \
  mt4-ea-live
