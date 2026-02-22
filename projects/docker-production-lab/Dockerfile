# syntax=docker/dockerfile:1.7

FROM python:3.12-slim AS builder
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_NO_CACHE_DIR=1
WORKDIR /build
COPY app/requirements.txt ./requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip wheel --wheel-dir /wheels -r requirements.txt

FROM python:3.12-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DATA_DIR=/data \
    APP_PORT=8080

RUN groupadd --system --gid 10001 app && \
    useradd --system --uid 10001 --gid app --create-home --home-dir /home/app app

WORKDIR /app
COPY app/requirements.txt ./requirements.txt
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && rm -rf /wheels
COPY app/app.py ./app.py
COPY app/entrypoint.sh ./entrypoint.sh
RUN chmod 755 /app/entrypoint.sh && mkdir -p /data && chown -R app:app /app /data

EXPOSE 8080
VOLUME ["/data"]
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2).read()"

USER app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "4", "app:app"]
