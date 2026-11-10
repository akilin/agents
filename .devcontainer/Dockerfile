FROM mcr.microsoft.com/devcontainers/typescript-node:latest

USER node
# Pre-create so the gh-config volume mounts owned by node, not root
RUN mkdir -p /home/node/.config/gh
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -fsSL https://aka.ms/apm-unix | sh
ENV PATH="/home/node/.local/bin:${PATH}"
