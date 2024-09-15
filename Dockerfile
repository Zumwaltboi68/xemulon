# Use the latest Debian base image
FROM debian:latest

# Set environment variables to run xemu headlessly
ENV DISPLAY=:0
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
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
    x11vnc \
    xvfb \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the xemu repository from GitHub
RUN git clone https://github.com/mborgerson/xemu.git /opt/xemu

# Set working directory
WORKDIR /opt/xemu

# Build xemu from source
RUN ./build.sh

# Install noVNC and websockify for web access
RUN mkdir /opt/novnc \
    && curl -L https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz | tar xz --strip-components=1 -C /opt/novnc \
    && curl -L https://github.com/novnc/websockify/archive/refs/tags/v0.9.0.tar.gz | tar xz --strip-components=1 -C /opt/novnc/utils/websockify

# Create a script to run xemu headlessly with noVNC
RUN echo '#!/bin/bash\n\
xvfb-run --auto-servernum --server-args="-screen 0 1280x800x24" /opt/xemu/dist/xemu &\n\
/opt/novnc/utils/launch.sh --vnc localhost:5900 --listen 8080' > /usr/local/bin/run-xemu-headless

# Make the script executable
RUN chmod +x /usr/local/bin/run-xemu-headless

# Expose the port for the web interface
EXPOSE 8080

# Set the default command to run xemu headlessly
CMD ["/usr/local/bin/run-xemu-headless"]
