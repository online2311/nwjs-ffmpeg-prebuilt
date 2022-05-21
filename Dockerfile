FROM node:12.22.12-buster as builder
RUN apt-get -y update && apt-get install -y build-essential curl git lsb-base lsb-release sudo apt-utils python pkg-config
RUN git clone https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt.git
WORKDIR /nwjs-ffmpeg-prebuilt
RUN npm install && node build --arch arm --version 0.54.1

FROM alpine:latest
COPY --from=builder /nwjs-ffmpeg-prebuilt/build/out/ .
ENTRYPOINT ["/bin/sh"]
