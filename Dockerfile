# Use Ubuntu base image
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Download and install Flutter (3.27.1 stable - compatible with Dart 3.4+)
RUN curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz \
    && tar xf flutter.tar.xz \
    && mv flutter /opt/flutter \
    && rm flutter.tar.xz

# Add Flutter to PATH
ENV PATH="/opt/flutter/bin:${PATH}"

# Fix git ownership issues
RUN git config --global --add safe.directory /opt/flutter \
    && git config --global --add safe.directory '*'

# Pre-download Flutter dependencies and accept licenses
RUN flutter doctor -v \
    && flutter precache --web \
    && yes | flutter doctor --android-licenses || true

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build Flutter web app
RUN flutter build web --release

# Expose port (Railway will set PORT env var)
EXPOSE 8080

# Install a simple static file server
RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Serve the built web app
CMD python3 -m http.server 8080 --directory build/web
