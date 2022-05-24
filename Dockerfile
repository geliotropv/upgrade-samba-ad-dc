FROM azul/zulu-openjdk:17

ARG RUN_UID=1000

ENV DOCKER_DISPLAY_NAME jdk17-ci-docker-v1
# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
# Installing packages
RUN rm -rf /var/lib/apt/lists/* && \
  apt-get update -yqq && \
  apt-get install -y --no-install-recommends git docker.io && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get autoclean && \
  apt-get clean

## Add build user account, values are set to default below
#ENV RUN_USER ci
#RUN id $RUN_USER || adduser --uid $RUN_UID \
#    --gecos 'Build User' \
#    --shell '/bin/sh' \
#    --disabled-login \
#    --disabled-password "$RUN_USER"
#
#ENV HOME /home/$RUN_USER
#
#USER $RUN_USER
