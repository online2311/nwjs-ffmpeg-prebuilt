FROM debian:10.12 as builder

RUN apt-get -y update && apt-get install -y --no-install-recommends apt-utils build-essential curl git lsb-base lsb-release sudo 
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
RUN curl -L https://raw.githubusercontent.com/chromium/chromium/main/build/install-build-deps.sh > /tmp/install-build-deps.sh && chmod +x /tmp/install-build-deps.sh && /tmp/install-build-deps.sh --no-prompt --no-arm --no-chromeos-fonts --no-nacl && rm /tmp/install-build-deps.sh

# Don't build as root.
RUN useradd chromium --shell /bin/bash --create-home && usermod -aG sudo chromium
USER chromium
ENV HOME /home/chromium
WORKDIR /home/chromium

RUN git clone https://github.com/online2311/nwjs-ffmpeg-prebuilt.git
ENV PATH="$PATH:/home/chromium/depot_tools"
RUN npx -y nwjs-ffmpeg-prebuilt --arch arm64 -v 0.54.1 -p linux
# RUN npx nwjs-ffmpeg-prebuilt --arch arm -v 0.54.1 -p linux
# RUN npx nwjs-ffmpeg-prebuilt --arch x64 -v 0.54.1 -p linux 
# RUN npx nwjs-ffmpeg-prebuilt --arch win -v 0.54.1 -p win32
# RUN npx nwjs-ffmpeg-prebuilt --arch win -v 0.54.1 -p win64
# RUN npx nwjs-ffmpeg-prebuilt --arch osx -v 0.54.1 -p osx


# FROM alpine:latest
# COPY --from=builder /nwjs-ffmpeg-prebuilt/build/out/ .
# VOLUME [ "/data" ]
ENTRYPOINT ["/bin/bash"]
