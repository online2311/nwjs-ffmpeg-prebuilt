FROM debian:10.12 as builder
RUN apt-get -y update && apt -y upgrade && apt-get install -y git sudo curl python
RUN curl -sL https://deb.nodesource.com/setup_18.x | sudo bash - && sudo apt-get install -y nodejs && sudo apt-get install -y gcc g++ make python python3
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python
RUN git clone https://github.com/online2311/nwjs-ffmpeg-prebuilt.git
RUN npx nwjs-ffmpeg-prebuilt --arch arm64 -v 0.54.1 -p linux
RUN npx nwjs-ffmpeg-prebuilt --arch arm -v 0.54.1 -p linux
RUN npx nwjs-ffmpeg-prebuilt --arch x64 -v 0.54.1 -p linux 
RUN npx nwjs-ffmpeg-prebuilt --arch win -v 0.54.1 -p win32
RUN npx nwjs-ffmpeg-prebuilt --arch win -v 0.54.1 -p win64
RUN npx nwjs-ffmpeg-prebuilt --arch osx -v 0.54.1 -p osx

FROM alpine:latest
COPY --from=builder /nwjs-ffmpeg-prebuilt/build/out/ .

ENTRYPOINT ["/bin/bash"]
