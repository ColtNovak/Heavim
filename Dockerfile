FROM archlinuxarm/base-devel:latest

RUN pacman -Syu --noconfirm --needed \
    git curl neovim nodejs npm python-pip \
    ripgrep fd fzf lua luarocks cmake make gcc \
    python-pynvim fastfetch \
    && rm -rf /var/cache/pacman/pkg/*

RUN mkdir -p /root/.config/nvim \
    && git clone --depth 1 https://github.com/ColtNovak/Heavim-neovim-config.git /root/.config/nvim \
    && rm -rf /root/.config/nvim/.git

RUN npm config set arch arm64 && \
    pip install --no-cache-dir pynvim

RUN curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.linux-arm64 -o /usr/bin/ttyd \
    && chmod +x /usr/bin/ttyd

WORKDIR /workspace
EXPOSE 8080

CMD ["ttyd", "-t", "disableReconnect=true", "-p", "8080", "bash", "-ic", "TERM=xterm-256color nvim"]
