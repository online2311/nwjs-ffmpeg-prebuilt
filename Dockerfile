FROM debian:10.12 as builder
RUN apt-get -y update && apt-get install -y build-essential curl git lsb-base lsb-release sudo apt-utils python
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs
RUN curl -L https://raw.githubusercontent.com/chromium/chromium/main/build/install-build-deps.sh > /tmp/install-build-deps.sh && chmod +x /tmp/install-build-deps.sh && /tmp/install-build-deps.sh --no-prompt --no-arm --no-chromeos-fonts --no-nacl && rm /tmp/install-build-deps.sh

# Don't build as root.
RUN useradd chromium --shell /bin/bash --create-home && usermod -aG sudo chromium
RUN echo "chromium ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER chromium
ENV HOME /home/chromium
WORKDIR /home/chromium

RUN git config --global url."https://github.com/google/angle.git".insteadOf "https://chromium.googlesource.com/angle/angle.git"
RUN git config --global url."https://github.com/chromium/chromium.git".insteadOf "https://chromium.googlesource.com/chromium/src.git"

RUN git clone https://github.com/online2311/nwjs-ffmpeg-prebuilt.git
ENV PATH="$PATH:/home/chromium/build/depot_tools"
RUN npx -y nwjs-ffmpeg-prebuilt --arch arm64 -v 0.54.1 -p linux

# FROM alpine:latest
# COPY --from=builder /home/chromium/nwjs-ffmpeg-prebuilt/build/out/ .
ENTRYPOINT ["/bin/bash"]
