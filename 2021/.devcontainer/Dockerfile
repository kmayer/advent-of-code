FROM ruby:2.7.2

RUN apt-get update \
  && apt-get install -y vim sudo man
COPY load-profile.sh /etc/profile.d/

ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -G sudo -m $USERNAME \
  && echo ${USERNAME}:password | chpasswd