FROM public.ecr.aws/lts/ubuntu:22.04_stable
ARG TARGETARCH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ADD https://cli.github.com/packages/githubcli-archive-keyring.gpg /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod 644 /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
RUN apt-get update -qq && \
    apt-get install -qy --no-install-recommends \
        ca-certificates gh git curl awscli jq && \
    rm -fr /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH}.tar.gz" \
    | tar -xzf - && \
    mv "yq_linux_${TARGETARCH}" /usr/bin/yq

# Crude smoke test.
RUN aws --version && \
    gh --version && \
    jq --version && \
    yq --version

RUN groupadd -g 1001 user && \
    useradd -mu 1001 -g user user

WORKDIR /home/user
USER user
CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/alphagov/govuk-infrastructure/tree/main/images/github-cli/
