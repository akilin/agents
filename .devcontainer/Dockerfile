FROM mcr.microsoft.com/devcontainers/typescript-node:latest

USER node
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -fsSL https://aka.ms/apm-unix | sh
ENV PATH="/home/node/.local/bin:${PATH}"
