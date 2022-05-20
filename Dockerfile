FROM debian:10.12 as builder
RUN apt-get update && apt -y upgrade && apt-get install -y git sudo curl 
RUN curl -sL https://deb.nodesource.com/setup_18.x | sudo bash - && sudo apt-get install -y nodejs
RUN git clone https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt.git
RUN export PATH=/build/depot_tools:$PATH
RUN npx nwjs-ffmpeg-prebuilt --arch arm64 -v 0.54.1 -p linux -o nwjs-arm64-v0.54.1.zip


FROM alpine:latest
COPY --from=builder nwjs-arm64-v0.54.1.zip .
RUN unzip -o /nwjs-arm64-v0.54.1.zip -d /data/
RUN file="$(file /data/libffmpeg.so)" && echo $file
VOLUME [ "/data" ]
ENTRYPOINT ["/bin/bash"]
