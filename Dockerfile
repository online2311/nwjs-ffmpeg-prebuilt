FROM debian:10.12 as builder
RUN apt-get -y update && apt -y upgrade && apt-get install -y git sudo curl python
RUN curl -sL https://deb.nodesource.com/setup_18.x | sudo bash - && sudo apt-get install -y nodejs && sudo apt-get install -y gcc g++ make python python3
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python
RUN git clone https://github.com/online2311/nwjs-ffmpeg-prebuilt.git
RUN export PATH=/nwjs-ffmpeg-prebuilt/build/depot_tools:$PATH

WORKDIR /nwjs-ffmpeg-prebuilt
RUN npm install && sudo npm build --arch arm64 -v 0.54.1 -p linux -o /nwjs-v0.54.1-linux-arm64.zip
RUN npm install && sudo npm build --arch arm -v 0.54.1 -p linux -o /nwjs-v0.54.1-linux-arm.zip
RUN npm install && sudo npm build --arch x64 -v 0.54.1 -p linux -o /nwjs-v0.54.1-linux-x64.zip
RUN npm install && sudo npm build --arch win -v 0.54.1 -p linux -o /nwjs-v0.54.1-win-x64.zip


FROM alpine:latest
COPY --from=builder /nwjs-v0.54.1-linux-arm64.zip .
COPY --from=builder /nwjs-v0.54.1-linux-arm.zip .
COPY --from=builder /nwjs-v0.54.1-linux-x64.zip .
COPY --from=builder /nwjs-v0.54.1-win-x64.zip .
RUN apk update && apk install file unzip
RUN unzip -o /nwjs-v0.54.1-linux-arm64.zip -d /data/nwjs-v0.54.1-linux-arm64/ && file="$(file /data/nwjs-v0.54.1-linux-arm64/libffmpeg.so)" && echo $file
RUN unzip -o /nwjs-v0.54.1-linux-arm.zip -d /data/nwjs-v0.54.1-linux-arm/ && file="$(file /data/nwjs-v0.54.1-linux-arm/libffmpeg.so)" && echo $file
RUN unzip -o /nwjs-v0.54.1-linux-x64.zip -d /data/nwjs-v0.54.1-linux-x64/ && file="$(file /data/nwjs-v0.54.1-linux-x64/libffmpeg.so)" && echo $file
RUN unzip -o /nwjs-v0.54.1-win-x64.zip -d /data/nwjs-v0.54.1-win-x64/ && file="$(file /data/nwjs-v0.54.1-win-x64/ffmpeg.dll)" && echo $file
RUN rm /nwjs-v0.54.1-linux-arm64.zip /nwjs-v0.54.1-linux-arm.zip /nwjs-v0.54.1-linux-x64.zip /nwjs-v0.54.1-win-x64.zip
RUN apk del file unzip && rm -rf /var/cache/apk/*

VOLUME [ "/data" ]
ENTRYPOINT ["/bin/bash"]
