FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq lsof net-tools dnsutils iproute2 iputils-ping traceroute \
    procps psmisc ufw cron rsyslog tcpdump stress-ng tree vim \
    && rm -rf /var/lib/apt/lists/*
