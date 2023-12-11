FROM public.ecr.aws/lts/ubuntu:22.04_stable
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV MONGO_VERSION 2.6.12
ARG mongo_tarball="mongodb-linux-x86_64-$MONGO_VERSION.tgz"
ARG mongo_url="https://fastdl.mongodb.org/linux/$mongo_tarball"

# hadolint ignore=DL3008
RUN apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    rm -rf /var/lib/apt/lists/*;
WORKDIR /tmp
RUN curl -SsfO "$mongo_url"; \
    sha256sum -c <(echo "6d6415ac068825d1aed23f9482080ce3551bfac828d9570be1d72990d5f441b0  $mongo_tarball"); \
    tar -xf "$mongo_tarball" -C /usr/local --strip-components=1; \
    rm -f "$mongo_tarball";

WORKDIR /data/configdb
WORKDIR /data/db
RUN useradd -Ur mongodb -d /data; \
    chown -R mongodb:mongodb /data;
USER mongodb
VOLUME /data/db /data/configdb
EXPOSE 27017
ENTRYPOINT ["mongod"]
LABEL org.opencontainers.image.source=https://github.com/alphagov/govuk-infrastructure/tree/main/images/mongodb/
