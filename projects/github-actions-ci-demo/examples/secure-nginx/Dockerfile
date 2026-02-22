# Author: Simon Parris
# Date: 2026-02-22
# Hardened example: minimal image, non-root runtime, explicit config, no package manager at runtime.
FROM nginxinc/nginx-unprivileged:1.27-alpine

USER root
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
RUN chown -R 101:101 /usr/share/nginx/html /etc/nginx && \
    chmod -R go-w /usr/share/nginx/html /etc/nginx

USER 101
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
