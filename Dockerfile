FROM node:12.22.12-buster as builder
ENV TZ Asia/Shanghai
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
RUN apt-get -y update && apt-get install -y -q build-essential curl git lsb-base lsb-release sudo apt-utils python pkg-config tzdata
# Don't build as root.
RUN useradd chromium --shell /bin/bash --create-home && usermod -aG sudo chromium
RUN echo "chromium ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER chromium
ENV HOME /home/chromium
WORKDIR /home/chromium

RUN git config --global url."https://github.com/google/angle.git".insteadOf "https://chromium.googlesource.com/angle/angle.git"
RUN git config --global url."https://github.com/chromium/chromium.git".insteadOf "https://chromium.googlesource.com/chromium/src.git"
RUN git clone https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt.git
RUN npx nwjs-ffmpeg-prebuilt --arch x64 --version 0.54.1 || true

WORKDIR /home/chromium/build/chromium/src
ENV PATH="$PATH:/home/chromium/build/depot_tools"
RUN python /home/chromium/build/chromium/src/build/linux/sysroot_scripts/install-sysroot.py --arch=arm64
RUN sed -i '/^assert/d' build/config/linux/atspi2/BUILD.gn && sed -i '/^assert/d' build/config/linux/atk/BUILD.gn
RUN gn gen out/Default --args='chrome_pgo_phase=0 is_debug=false enable_nacl=false is_component_ffmpeg=true proprietary_codecs=true is_official_build=true target_cpu="arm64" ffmpeg_branding="Chrome"'
RUN autoninja -C out/Default/ libffmpeg.so
RUN libffmpeg=$(file out/Default/libffmpeg.so) && echo "$libffmpeg"

FROM alpine:latest
COPY --from=builder /home/chromium/build/chromium/src/out/Default/libffmpeg.so files/
RUN apk add --update bash file && rm -rf /var/cache/apk/*
