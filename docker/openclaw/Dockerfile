ARG OPENCLAW_BASE_IMAGE=ghcr.io/openclaw/openclaw:latest

FROM ${OPENCLAW_BASE_IMAGE}

USER root

ENV HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
ENV HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
ENV HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      file \
      git \
      locales \
      procps \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /home/linuxbrew/.linuxbrew; \
    chown -R node:node /home/linuxbrew; \
    { \
      echo 'export HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew'; \
      echo 'export HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew'; \
      echo 'export HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar'; \
      echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"'; \
    } > /etc/profile.d/homebrew.sh

USER node

RUN set -eux; \
    NONINTERACTIVE=1 CI=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
    brew analytics off; \
    brew --version; \
    brew doctor || true

USER root

RUN set -eux; \
    rm -f /usr/local/bin/brew; \
    { \
      echo '#!/bin/sh'; \
      echo 'exec /home/linuxbrew/.linuxbrew/bin/brew "$@"'; \
    } > /usr/local/bin/brew; \
    chmod 0755 /usr/local/bin/brew

USER node
