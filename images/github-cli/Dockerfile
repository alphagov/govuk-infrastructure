ARG base_image=bitnami/minideb:latest

FROM ${base_image}

RUN apt-get update -qq && apt-get install -y ca-certificates git wget

ADD https://cli.github.com/packages/githubcli-archive-keyring.gpg /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod 644 /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    gh \
    awscli \
    podman 

RUN aws --version && podman --version

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz -O - |  tar xz && mv yq_linux_amd64 /usr/bin/yq

RUN groupadd -g 1001 -r user && useradd -u 1001 -m -r -g user user

ENV HOME=/home/user

RUN chown -R user:user $HOME
WORKDIR $HOME

USER user

CMD /bin/bash
