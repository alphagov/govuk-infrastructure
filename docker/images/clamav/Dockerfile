ARG base_image=bitnami/minideb:latest

FROM ${base_image}

RUN apt-get update -qq && apt-get install -y clamav clamav-daemon

RUN groupadd -g 1001 -r user && useradd -u 1001 -m -r -g user user

ENV HOME=/home/user

RUN chown -R user:user $HOME
WORKDIR $HOME

USER user

CMD /bin/bash
