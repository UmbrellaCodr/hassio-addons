# https://github.com/Microsoft/vscode-dev-containers
# https://github.com/microsoft/vscode-dev-containers/blob/main/containers/docker-in-docker/.devcontainer/Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:dev-bullseye

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="false"
# [Option] Engine/CLI Version
ARG DOCKER_VERSION="latest"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1

RUN git clone \
    --depth 1  \
    --filter=blob:none  \
    --sparse \
    https://github.com/microsoft/vscode-dev-containers.git
RUN cd vscode-dev-containers; git sparse-checkout set containers/docker-in-docker/.devcontainer/library-scripts; cd ..
RUN mkdir -p /tmp/library-scripts/; cp /vscode-dev-containers/containers/docker-in-docker/.devcontainer/library-scripts/*.sh /tmp/library-scripts/

RUN apt-get update -qq

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" "${DOCKER_VERSION}"

VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine
# inside the container "overrideCommand": false is set in devcontainer.json.
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

RUN apt-get update -qq && apt-get install -qqy \
    shellcheck \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    zsh \
    jq \
    curl \
    avahi-daemon \
    apparmor-utils \
    udisks2 \
    libglib2.0-bin \
    network-manager \
    dbus \
    wget \
    iputils-ping

#Clean up
RUN rm -rf /vscode-dev-containers
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

#RUN wget https://github.com/home-assistant/os-agent/releases/download/1.2.2/os-agent_1.2.2_linux_aarch64.deb
#RUN apt install ./os-agent_1.2.2_linux_aarch64.deb -qqy || true
#RUN wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
#RUN apt install ./homeassistant-supervised.deb -qqy || true

COPY supervisor.sh /usr/bin/
