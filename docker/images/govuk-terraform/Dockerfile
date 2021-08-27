ARG DEBIAN_VERSION=11.0-slim
FROM debian:${DEBIAN_VERSION}

ARG AWSCLI_VERSION=2.0.30
ARG TERRAFORM_VERSION=1.0.0
ARG TERRAFORM_SUM=8be33cc3be8089019d95eb8f546f35d41926e7c1e5deff15792e969dde573eb5
ARG AWSCLI_SUM=7ee475f22c1b35cc9e53affbf96a9ffce91706e154a9441d0d39cbf8366b718e

ENV PATH $PATH:/usr/local/bin
ARG PACKAGES="jq curl unzip git"

RUN apt-get update \
    && apt-get install -y ${PACKAGES}

ARG TERRAFORM_ZIP=terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN set -ex \
    && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP} -o /tmp/${TERRAFORM_ZIP} \
    && echo "${TERRAFORM_SUM}  /tmp/${TERRAFORM_ZIP}" | sha256sum -c - \
    && unzip /tmp/${TERRAFORM_ZIP} -d /usr/local/bin \
    && rm /tmp/${TERRAFORM_ZIP}

ARG AWSCLI_ZIP=awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip

RUN set -ex \
    && curl "https://awscli.amazonaws.com/${AWSCLI_ZIP}" -o "/tmp/${AWSCLI_ZIP}" \
    && echo "${AWSCLI_SUM}  /tmp/${AWSCLI_ZIP}" | sha256sum -c - \
    && unzip /tmp/${AWSCLI_ZIP} -d /tmp/aws_${AWSCLI_VERSION} \
    && ./tmp/aws_${AWSCLI_VERSION}/aws/install \
    && rm -rf /tmp/${AWSCLI_ZIP} /tmp/aws_${AWSCLI_VERSION}
