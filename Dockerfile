# FROM debian:10.12 as builder
FROM ubuntu:20.04 as builder
RUN apt-get -y update && apt-get install -y build-essential curl git lsb-base lsb-release sudo apt-utils python2
RUN curl -sL https://deb.nodesource.com/setup_18.x | sudo bash - && sudo apt-get install -y nodejs

# Don't build as root.
RUN useradd chromium --shell /bin/bash --create-home && usermod -aG sudo chromium
RUN echo "chromium ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER chromium
ENV HOME /home/chromium
WORKDIR /home/chromium

RUN git config --global url."https://github.com/google/angle.git".insteadOf "https://chromium.googlesource.com/angle/angle.git"
RUN git config --global url."https://github.com/chromium/chromium.git".insteadOf "https://chromium.googlesource.com/chromium/src.git"

RUN git clone https://github.com/online2311/nwjs-ffmpeg-prebuilt.git
# ENV PATH="$PATH:/home/chromium/build/depot_tools"
RUN npx -y nwjs-ffmpeg-prebuilt --version 0.54.1
RUN python /home/chromium/build/chromium/src/build/linux/sysroot_scripts/install-sysroot.py --arch=arm64
RUN npx -y nwjs-ffmpeg-prebuilt --arch arm64 --version 0.54.1
# FROM alpine:latestrnv
# COPY --from=builder /home/chromium/build/out/ .
ENTRYPOINT ["/bin/bash"]
