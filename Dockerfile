FROM node:12.22.12-buster as builder
RUN apt-get -y update && apt-get install -y build-essential curl git lsb-base lsb-release sudo apt-utils python pkg-config
RUN git clone https://github.com/online2311/nwjs-ffmpeg-prebuilt.git
WORKDIR /nwjs-ffmpeg-prebuilt
RUN npm install && node build --arch arm64 --version 0.54.1

FROM alpine:latest
COPY --from=builder /nwjs-ffmpeg-prebuilt/build/out/ .
ENTRYPOINT ["/bin/sh"]
