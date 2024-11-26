FROM --platform=$TARGETPLATFORM public.ecr.aws/lts/ubuntu:24.04
ARG TARGETARCH
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ARG github_apt_repo=https://cli.github.com/packages
ARG keyrings_dir=/usr/share/keyrings
WORKDIR $keyrings_dir
# hadolint ignore=DL3020
ADD ${github_apt_repo}/githubcli-archive-keyring.gpg github.gpg
ADD https://pgp.mongodb.com/server-7.0.pub mongodb.gpg
# hadolint ignore=DL3008
RUN apt-get update -qq ; \
    apt-get install -qy --no-install-recommends ca-certificates ; \
    chmod 644 github.gpg mongodb.gpg;  \
    echo "deb [arch=${TARGETARCH} signed-by=${keyrings_dir}/github.gpg] ${github_apt_repo} stable main" > /etc/apt/sources.list.d/github.list ; \
    echo "deb [arch=${TARGETARCH} signed-by=${keyrings_dir}/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb.list ; \
    apt-get update -qq ; \
    apt-get install -qy --no-install-recommends \
        curl file gh git jq libarchive-tools mysql-client netcat-openbsd \
        postgresql-client pv wget2 gettext mongodb-mongosh=2.2.10 \
        mongodb-database-tools=100.9.4 redis-tools ; \
    rm -fr /var/lib/apt/lists/*

ARG yq_package_url=https://github.com/mikefarah/yq/releases/latest/download
ARG yq_binary="yq_linux_${TARGETARCH}"
WORKDIR /tmp
RUN curl -fsSL "${yq_package_url}/${yq_binary}.tar.gz" \
        | tar -xzf - ; \
    cp "${yq_binary}" /usr/bin/yq ; \
    rm -fr /tmp/*

ARG awscli_install_dir=/opt
RUN curl -Ssf "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" \
        | bsdtar -C "${awscli_install_dir}" -xf - \
          --exclude 'aws_completer' --exclude 'docutils' --exclude 'examples' \
          --exclude 'install' --exclude 'topics' ; \
    chmod +x "${awscli_install_dir}/aws/dist/aws"
ENV PATH=$PATH:$awscli_install_dir/aws/dist

COPY --from=peakcom/s5cmd:v2.2.2 s5cmd /bin/s5cmd

RUN groupadd -g 1001 user ; \
    useradd -mu 1001 -g user user
WORKDIR /home/user
USER user

# Crude smoke test.
RUN aws --version ; \
    gh --version ; \
    jq --version ; \
    echo -n "mongosh "; mongosh --version ; \
    mongodump --version ; \
    mysql --version ; \
    psql --version ; \
    redis-cli --version ; \
    echo -n "s5cmd "; s5cmd version ; \
    yq --version

CMD ["/bin/bash"]
LABEL org.opencontainers.image.source=https://github.com/alphagov/govuk-infrastructure/tree/main/images/toolbox/
