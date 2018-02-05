FROM alpine:latest

# ALSO CHECK OPTIMIZED OR BETTER WAY TO SETUP DOCKERFILE 'MultiStage_optimized_Dockerfile'
#.I h'v commented this file with relevant gotchas to watch-out for
# Define build argument for version
ARG VERSION=1.12.2

RUN set -x                                                        && \
                                                                     \
# Install necessary build tools, libraries and utilities                       \
    apk add --no-cache --virtual .build-deps                         \
        build-base                                                   \
        gnupg                                                        \
        pcre-dev                                                     \
        wget                                                         \
        zlib-dev                                                  && \
                                                                     \
# Retrieve, verify and unpack Nginx source **Not a good practice     \
# Never a good practice to combine all instruction in single RUN instruction \
    TMP="$(mktemp -d)" && cd "$TMP"                               && \
    gpg --keyserver pgp.mit.edu --recv-keys                          \
        B0F4253373F8F6F510D42178520A9993A1C052F8                  && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz     && \
    wget -q http://nginx.org/download/nginx-${VERSION}.tar.gz.asc && \
    gpg --verify nginx-${VERSION}.tar.gz.asc                      && \
    tar -xf nginx-${VERSION}.tar.gz                               && \
                                                                     \
# Build and install nginx                                            \
# Note that statically building the Application artefact is the best \
# way to address dependency of App runtime                           \     
    cd nginx-${VERSION}                                           && \
    ./configure                                                      \
        --with-ld-opt="-static"                                      \
        --with-http_sub_module                                    && \
    make install                                                  && \
    strip /usr/local/nginx/sbin/nginx                             && \
                                                                     \
# Clean up                                                           \
    cd / && rm -rf "$TMP"                                         && \
    apk del .build-deps                                           && \
                                                                     \
# Symlink access and error logs to /dev/stdout and /dev/stderr,      \
# in order to make use of Docker's logging mechanism                 \
    ln -sf /dev/stdout /usr/local/nginx/logs/access.log           && \
    ln -sf /dev/stderr /usr/local/nginx/logs/error.log

# Customise static content, and configuration
COPY index.html /usr/local/nginx/html/
COPY nginx.conf /usr/local/nginx/conf/

# Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

# Expose port
EXPOSE 80

# Define entrypoint and default parameters. The "daemon off" mode ensures App runs in Foreground
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
