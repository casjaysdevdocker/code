# Docker image for code using the xorg template
ARG LICENSE="MIT"
ARG IMAGE_NAME="code"
ARG PHP_SERVER="code"
ARG BUILD_DATE="Thu Mar 16 07:09:45 PM EDT 2023"
ARG LANGUAGE="en_US.UTF-8"
ARG TIMEZONE="America/New_York"
ARG WWW_ROOT_DIR="/data/htdocs"
ARG DEFAULT_FILE_DIR="/usr/local/share/template-files"
ARG DEFAULT_DATA_DIR="/usr/local/share/template-files/data"
ARG DEFAULT_CONF_DIR="/usr/local/share/template-files/config"
ARG DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"

ARG IMAGE_REPO="debian"
ARG IMAGE_VERSION="latest"
ARG CONTAINER_VERSION="${IMAGE_VERSION}"

ARG SERVICE_PORT=""
ARG EXPOSE_PORTS="1-65535"

ARG USER="root"
ARG DISTRO_VERSION="${IMAGE_VERSION}"
ARG BUILD_VERSION="${DISTRO_VERSION}"

FROM tianon/gosu:latest AS gosu
FROM ${IMAGE_REPO}:${IMAGE_VERSION} AS build
ARG USER
ARG LANGUAGE
ARG LICENSE
ARG TIMEZONE
ARG IMAGE_NAME
ARG PHP_SERVER
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG NODE_VERSION
ARG NODE_MANAGER
ARG BUILD_VERSION
ARG WWW_ROOT_DIR
ARG DEFAULT_FILE_DIR
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION

ARG PACK_LIST="bash bash-completion git curl wget sudo unzip tini xz-utils iproute2 locales procps net-tools bsd-mailx  xorg x11-apps\
  "

ENV ENV=~/.bashrc
ENV SHELL="/bin/sh"
ENV TZ="${TIMEZONE}"
ENV TIMEZONE="${TZ}"
ENV LANG="${LANGUAGE}"
ENV TERM="xterm-256color"
ENV HOSTNAME="casjaysdev-code"
ENV DEBIAN_FRONTEND="noninteractive"

USER ${USER}
WORKDIR /root

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
COPY ./rootfs/. /

RUN set -ex; \
  mkdir -p "${DEFAULT_DATA_DIR}" "${DEFAULT_CONF_DIR}" "${DEFAULT_TEMPLATE_DIR}" ; \
  apt-get update && apt-get install -yy locales && echo "$LANG UTF-8" >"/etc/locale.gen" ; \
  dpkg-reconfigure --frontend=noninteractive locales ; update-locale LANG=$LANG ; \
  echo 'export DEBIAN_FRONTEND="'${DEBIAN_FRONTEND}'"' >"/etc/profile.d/apt.sh" && chmod 755 "/etc/profile.d/apt.sh" && \
  DEBIAN_CODENAME="$(grep -s 'VERSION_CODENAME=' /etc/os-release | awk -F'=' '{print $2}')" ; \
  [ -z "$DEBIAN_CODENAME" ] || sed -i "s|$DEBIAN_CODENAME|$DISTRO_VERSION|g" "/etc/apt/sources.list" ; \
  apt-get update -yy && apt-get upgrade -yy && apt-get install -yy ${PACK_LIST}

RUN useradd --shell /bin/bash --create-home --home-dir /home/x11user x11user && \
  usermod -a -G audio,video,sudo,tty,dialout,cdrom,floppy,audio,dip,video,plugdev x11user && \
  echo "x11user ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/x11user" ; \
  chown -Rf x11user:x11user "/home/x11user"

RUN touch "/etc/profile" "/root/.profile" ; \
  { [ -f "/etc/bash/bashrc" ] && cp -Rf "/etc/bash/bashrc" "/root/.bashrc" ; } || { [ -f "/etc/bashrc" ] && cp -Rf "/etc/bashrc" "/root/.bashrc" ; } || { [ -f "/etc/bash.bashrc" ] && cp -Rf "/etc/bash.bashrc" "/root/.bashrc" ; }; \
  sed -i 's|root:x:.*|root:x:0:0:root:/root:/bin/bash|g' "/etc/passwd" ; \
  grep -s -q 'alias quit' "/root/.bashrc" || printf '# Profile\n\n%s\n%s\n%s\n' '. /etc/profile' '. /root/.profile' "alias quit='exit 0 2>/dev/null'" >>"/root/.bashrc" ; \
  [ -f "/usr/local/etc/docker/env/default.sample" ] && [ -d "/etc/profile.d" ] && \
  cp -Rf "/usr/local/etc/docker/env/default.sample" "/etc/profile.d/container.env.sh" && chmod 755 "/etc/profile.d/container.env.sh" ; \
  update-alternatives --install /bin/sh sh /bin/bash 1

RUN set -ex ; \
  wget -qO- "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor >/tmp/packages.microsoft.gpg && \
  install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" >"/etc/apt/sources.list.d/vscode.list" && \
  apt-get update -yy && apt-get upgrade -yy && apt-get install -yy code 

USER x11user
WORKDIR /home/${USER}
RUN echo "Installing code for $USER" ; \
  code --install-extension "aaron-bond.better-comments" --force ; \
  code --install-extension "bengreenier.vscode-node-readme" --force ; \
  code --install-extension "bierner.emojisense" --force ; \
  code --install-extension "bierner.github-markdown-preview" --force ; \
  code --install-extension "bierner.markdown-checkbox" --force ; \
  code --install-extension "bierner.markdown-emoji" --force ; \
  code --install-extension "bierner.markdown-footnotes" --force ; \
  code --install-extension "bierner.markdown-mermaid" --force ; \
  code --install-extension "bierner.markdown-preview-github-styles" --force ; \
  code --install-extension "bierner.markdown-yaml-preamble" --force ; \
  code --install-extension "bmalehorn.vscode-fish" --force ; \
  code --install-extension "bungcip.better-toml" --force ; \
  code --install-extension "christian-kohler.npm-intellisense" --force ; \
  code --install-extension "Cjay.ruby-and-rails-snippets" --force ; \
  code --install-extension "compilouit.manpage" --force ; \
  code --install-extension "coolbear.systemd-unit-file" --force ; \
  code --install-extension "d9705996.perl-toolbox" --force ; \
  code --install-extension "DavidAnson.vscode-markdownlint" --force ; \
  code --install-extension "dbaeumer.vscode-eslint" --force ; \
  code --install-extension "denoland.vscode-deno" --force ; \
  code --install-extension "dnicolson.binary-plist" --force ; \
  code --install-extension "dotiful.dotfiles-syntax-highlighting" --force ; \
  code --install-extension "DotJoshJohnson.xml" --force ; \
  code --install-extension "dsznajder.es7-react-js-snippets" --force ; \
  code --install-extension "duniul.dircolors" --force ; \
  code --install-extension "dunstontc.viml" --force ; \
  code --install-extension "EditorConfig.EditorConfig" --force ; \
  code --install-extension "eiminsasete.apacheconf-snippets" --force ; \
  code --install-extension "esbenp.prettier-vscode" --force ; \
  code --install-extension "file-icons.file-icons" --force ; \
  code --install-extension "formulahendry.auto-rename-tag" --force ; \
  code --install-extension "foxundermoon.shell-format" --force ; \
  code --install-extension "ginfuru.ginfuru-vscode-jekyll-syntax" --force ; \
  code --install-extension "ginfuru.vscode-jekyll-snippets" --force ; \
  code --install-extension "glenn2223.live-sass" --force ; \
  code --install-extension "hangxingliu.vscode-nginx-conf-hint" --force ; \
  code --install-extension "HexcodeTechnologies.vscode-prettydiff" --force ; \
  code --install-extension "hogashi.crontab-syntax-highlight" --force ; \
  code --install-extension "justusadam.language-haskell" --force ; \
  code --install-extension "keyring.Lua" --force ; \
  code --install-extension "malmaud.tmux" --force ; \
  code --install-extension "MariusAlchimavicius.json-to-ts" --force ; \
  code --install-extension "mechatroner.rainbow-csv" --force ; \
  code --install-extension "mrmlnc.vscode-apache" --force ; \
  code --install-extension "ms-azuretools.vscode-docker" --force ; \
  code --install-extension "ms-vscode-remote.remote-containers" --force ; \
  code --install-extension "ms-vscode.powershell" --force ; \
  code --install-extension "ms-vscode.vscode-typescript-tslint-plugin" --force ; \
  code --install-extension "nico-castell.linux-desktop-file" --force ; \
  code --install-extension "octref.vetur" --force ; \
  code --install-extension "oderwat.indent-rainbow" --force ; \
  code --install-extension "piotrpalarz.vscode-gitignore-generator" --force ; \
  code --install-extension "quicktype.quicktype" --force ; \
  code --install-extension "rebornix.ruby" --force ; \
  code --install-extension "redhat.vscode-yaml" --force ; \
  code --install-extension "ritwickdey.LiveServer" --force ; \
  code --install-extension "rohgarg.jekyll-post" --force ; \
  code --install-extension "rpinski.shebang-snippets" --force ; \
  code --install-extension "sastan.twind-intellisense" --force ; \
  code --install-extension "Shan.code-settings-sync" --force ; \
  code --install-extension "sidneys1.gitconfig" --force ; \
  code --install-extension "sissel.shopify-liquid" --force ; \
  code --install-extension "streetsidesoftware.code-spell-checker" --force ; \
  code --install-extension "swyphcosmo.spellchecker" --force ; \
  code --install-extension "syler.sass-indented" --force ; \
  code --install-extension "tanming363.bootstrap-v4" --force ; \
  code --install-extension "timonwong.shellcheck" --force ; \
  code --install-extension "TzachOvadia.todo-list" --force ; \
  code --install-extension "VisualStudioExptTeam.intellicode-api-usage-examples" --force ; \
  code --install-extension "VisualStudioExptTeam.vscodeintellicode" --force ; \
  code --install-extension "vscode-icons-team.vscode-icons" --force ; \
  code --install-extension "vscode-snippet.snippet" --force ; \
  code --install-extension "WakaTime.vscode-wakatime" --force ; \
  code --install-extension "wingrunr21.vscode-ruby" --force ; \
  code --install-extension "Wscats.eno" --force ; \
  code --install-extension "yinfei.luahelper" --force ; \
  code --install-extension "yzhang.markdown-all-in-one" --force ; \
  code --install-extension "ZainChen.json" --force ; \
  curl -q -LSsf "https://github.com/casjay/vs-code/raw/main/settings-linux.json" -o "$HOME/.config/Code/User/settings.json"

USER root
WORKDIR /root
RUN echo 'Running cleanup' ; \
  apt-get clean

RUN rm -Rf "/config" "/data" ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* ; \
  rm -rf /lib/systemd/system/anaconda.target.wants/*; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -Rf /usr/share/doc/* /usr/share/info/* /tmp/* /var/tmp/* /var/cache/*/* ; \
  if [ -d "/lib/systemd/system/sysinit.target.wants" ]; then cd "/lib/systemd/system/sysinit.target.wants" && rm -f $(ls | grep -v systemd-tmpfiles-setup) ; fi

RUN echo "Init done"

FROM scratch
ARG USER="x11user"
ARG LICENSE
ARG LANGUAGE
ARG TIMEZONE
ARG IMAGE_NAME
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.com>"
LABEL org.opencontainers.image.vendor="CasjaysDev"
LABEL org.opencontainers.image.authors="CasjaysDev"
LABEL org.opencontainers.image.vcs-type="Git"
LABEL org.opencontainers.image.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.base.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.license="${LICENSE}"
LABEL org.opencontainers.image.vcs-ref="${BUILD_VERSION}"
LABEL org.opencontainers.image.build-date="${BUILD_DATE}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.schema-version="${BUILD_VERSION}"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}"
LABEL com.github.containers.toolbox="false"

ENV ENV=~/.bashrc
ENV SHELL="/bin/bash"
ENV TZ="${TIMEZONE}"
ENV TIMEZONE="${TZ}"
ENV LANG="${LANGUAGE}"
ENV PORT="${SERVICE_PORT}"
ENV ENV_PORTS="${EXPOSE_PORTS}"
ENV TERM="xterm-256color"
ENV CONTAINER_NAME="${IMAGE_NAME}"
ENV HOSTNAME="casjaysdev-${IMAGE_NAME}"
ENV USER="${USER}"

COPY --from=build /. /

WORKDIR /home/${USER}
VOLUME [ "/tmp/.X11-unix", "/home/${USER}/.Xauthority", "/config", "/data" ]

EXPOSE ${ENV_PORTS}

CMD [ "" ]
ENTRYPOINT [ "tini", "--", "/usr/local/bin/entrypoint.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint.sh", "healthcheck" ]
