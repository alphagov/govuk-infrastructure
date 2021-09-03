ARG DEBIAN_VERSION=11.0-slim
FROM debian:${DEBIAN_VERSION}

ARG AWSCLI_VERSION=2.0.30
ARG TERRAFORM_VERSION=1.0.5
ARG TERRAFORM_SUM=7ce24478859ab7ca0ba4d8c9c12bb345f52e8efdc42fa3ef9dd30033dbf4b561
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
