# Author: Simon Parris
# Date: 2026-02-22
FROM python:3.12-alpine
WORKDIR /app
COPY server.py /app/server.py
RUN addgroup -S app && adduser -S -G app app && mkdir -p /data && chown -R app:app /app /data
USER app
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=2s --start-period=5s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
CMD ["python", "/app/server.py"]
