FROM debian:buster-slim

ENV RUNNER_NAME "runner"
ENV GITHUB_PAT ""
ENV GITHUB_TOKEN ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR "_work"
ENV RUNNER_LABELS "self-hosted"
ENV ADDITIONAL_PACKAGES ""
ENV RUNNER_TIMEOUT "7200"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        iputils-ping \
        build-essential \
        pkg-config \
        libssl-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER github
WORKDIR /home/github

RUN GITHUB_RUNNER_VERSION=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | jq -r '.tag_name[1:]') \
    && curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && sudo ./bin/installdependencies.sh

COPY --chown=github:github entrypoint.sh ./
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
