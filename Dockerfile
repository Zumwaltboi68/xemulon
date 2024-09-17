# Use debian:latest as the base image
FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libsdl2-dev \
    libepoxy-dev \
    libpixman-1-dev \
    libgtk-3-dev \
    libssl-dev \
    libsamplerate0-dev \
    libpcap-dev \
    ninja-build \
    python3-yaml \
    libslirp-dev \
    curl \
    novnc \
    websockify \
    x11vnc \
    xvfb \
    xfce4 \
    dbus-x11 \
    --no-install-recommends

# Clone and build xemu from the official repo
RUN git clone https://github.com/mborgerson/xemu.git /xemu && \
    cd /xemu && \
    ./build.sh

# Install noVNC and configure VNC environment
RUN mkdir -p /opt/novnc/utils/websockify && \
    ln -s /usr/share/novnc /opt/novnc/utils/websockify

# Create a script to run xemu headlessly in noVNC without a VNC password
RUN echo '#!/bin/bash\n\
    export DISPLAY=:1\n\
    Xvfb :1 -screen 0 1024x768x16 &\n\
    x11vnc -nopw -display :1 -N -forever &\n\
    websockify --web=/usr/share/novnc/ --wrap-mode=ignore 0.0.0.0:$PORT localhost:5900 &\n\
    cd /xemu && ./dist/xemu\n' > /xemu_run.sh && chmod +x /xemu_run.sh

# Expose the web VNC port (Render will dynamically set the $PORT variable)
EXPOSE 8080

# Run the xemu emulator via noVNC without password protection
CMD ["/xemu_run.sh"]
