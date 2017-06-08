FROM alpine:3.6

MAINTAINER Alessandro Molari <molari.alessandro@gmail.com> (alem0lars)

# ────────────────────────────────────────────── Setup basic system packages ──┐

RUN apk update \
 && apk upgrade

# Install libraries
RUN apk add --update --no-cache \
    linux-headers build-base openssl-dev libc-dev libxml2-dev libxslt-dev \
    libffi-dev readline-dev jemalloc-dev

# Install programs
RUN apk add --update --no-cache \
    git bash curl wget zsh

## Install common libraries.
#RUN apk add --update --no-cache                                                \
#    curl-dev                                                                   \
#    db-dev                                                                     \
#    geoip-dev                                                                  \
#    glib-dev                                                                   \
#    krb5-dev                                                                   \
#    libevent-dev                                                               \
#    libffi-dev                                                                 \
#    libbz2                                                                     \
#    libxml2-dev                                                                \
#    libxslt-dev                                                                \
#    libssl1.0                                                                  \
#    libtool                                                                    \
#    libwebp-dev                                                                \
#    libjpeg-turbo-dev                                                          \
#    libpng-dev                                                                 \
#    libpq                                                                      \
#    linux-headers                                                              \
#    ncurses                                                                    \
#    ncurses-dev                                                                \
#    readline-dev                                                               \
#    sqlite-dev                                                                 \
#    yaml-dev
#
## Install basic packages.
#RUN apk add --update --no-cache                                                \
#    autoconf                                                                   \
#    automake                                                                   \
#    ca-certificates                                                            \
#    curl                                                                       \
#    file                                                                       \
#    g++                                                                        \
#    gcc                                                                        \
#    make                                                                       \
#    tar                                                                        \
#    vim                                                                        \
#    xz                                                                         \
#    zsh

# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────── Setup common environment variables ──┐

ENV HOME /root

# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────── Setup ruby (1) ──┐

ENV RUBY_MAJOR=2.3                                                             \
    RUBY_VERSION=2.3.1                                                         \
    RUBY_DOWNLOAD_SHA1=c39b4001f7acb4e334cb60a0f4df72d434bef711                \
    RUBYGEMS_VERSION=2.6.6

ENV BUNDLER_VERSION 1.12.5

# TODO check if needed
# # Install ruby dependencies.
# RUN apk add --update --no-cache                                                \
#     bison                                                                      \
#     gdbm-dev

# Install ruby-install
RUN wget -O ruby-install-0.6.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz
RUN tar -xzvf ruby-install-0.6.0.tar.gz
RUN cd ruby-install-0.6.0/ && make install

# Install ruby
RUN ruby-install --system ruby $RUBY_VERSION

# Install things globally and don't create `.bundle` in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="${GEM_HOME}"                                                  \
    BUNDLE_BIN="${GEM_HOME}/bin"                                               \
    BUNDLE_SILENCE_ROOT_WARNING=1                                              \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p  "${GEM_HOME}" "${BUNDLE_BIN}"                                    \
 && chmod 777 "${GEM_HOME}" "${BUNDLE_BIN}"

# Install bundler
RUN gem install bundler --version "${BUNDLER_VERSION}"

# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup ssh ──┐

# Install ssh daemon
RUN apk add --update --no-cache                                                \
    openssh

# Generate fresh keys
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa                       \
 && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

# Prepare ssh run directory
RUN mkdir -p /var/run/sshd

# Configure ssh
RUN echo "StrictHostKeyChecking=no" >> /etc/ssh/ssh_config
RUN sed -i 's|[#]*PasswordAuthentication yes|PasswordAuthentication no|g'      \
    /etc/ssh/sshd_config

# Expose ssh port
EXPOSE 22

# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup git ──┐

ARG GIT_PWD="git"
ENV GIT_USER="git"
ENV GIT_GROUP="git"
ENV GIT_REPOS_DIR="/git"

# Install git packages.
RUN apk add --update --no-cache                                                \
    git-daemon                                                                 \
    git

# Setup a git user and ssh.
RUN addgroup "${GIT_GROUP}"                                                    \
 && echo -e "${GIT_PWD}\n${GIT_PWD}\n"                                         \
  | adduser -G "${GIT_GROUP}" -h "${GIT_REPOS_DIR}" -s /usr/bin/git-shell "${GIT_USER}"

# Remove the annoying `/etc/motd`.
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

# Configure local git client.
# TODO: Replace with fizzy config (when `--no-ask` is implemented).
RUN git config --global push.default simple                                    \
 && git config --global user.name  root                                        \
 && git config --global user.email root@localhost.localdomain

# SSH keys for user `root`
ADD docker/ssh_key.pub "/root/.ssh/authorized_keys"
ADD docker/ssh_key.pub "/root/.ssh/id_rsa.pub"
ADD docker/ssh_key     "/root/.ssh/id_rsa"
RUN chmod 700 "/root/.ssh"
RUN chmod 600 /root/.ssh/*

# SSH keys for user `git`
ADD docker/ssh_key.pub "${GIT_REPOS_DIR}/.ssh/authorized_keys"
ADD docker/ssh_key.pub "${GIT_REPOS_DIR}/.ssh/id_rsa.pub"
ADD docker/ssh_key     "${GIT_REPOS_DIR}/.ssh/id_rsa"
RUN chmod 700 "${GIT_REPOS_DIR}/.ssh"
RUN chmod 600 ${GIT_REPOS_DIR}/.ssh/*
RUN chown -R "${GIT_USER}:${GIT_GROUP}" "${GIT_REPOS_DIR}/.ssh"

# ─────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────────────────────────── Setup fizzy ──┐

# Install fizzy dependencies
RUN gem install thor
RUN apk add --update --no-cache                                                \
    sudo

# Install fizzy
RUN curl -sL                                                                   \
    https://raw.githubusercontent.com/alem0lars/fizzy/master/build/fizzy       \
  | tee /usr/local/bin/fizzy > /dev/null                                       \
 && chmod +x /usr/local/bin/fizzy

# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────── Setup ruby (2) ──┐

# Configure ruby
RUN fizzy cfg s -C ruby -U https:alem0lars/configs-ruby                        \
RUN fizzy qi -V docker-test-box -C ruby -I ruby

# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup app ──┐

ENV APP_DIR="${HOME}/fizzy"

# ──────────────────────────── (trick to allow caching) Install dependencies ──┤

# WORKDIR /tmp
# ADD ./Gemfile      Gemfile
# ADD ./Gemfile.lock Gemfile.lock
# RUN bundle install
# RUN rm ./Gemfile                                                               \
#  && rm ./Gemfile.lock

# ────────────────────────────────────────────────────────────── Add the app ──┤

ADD . "${APP_DIR}"
WORKDIR "${APP_DIR}"
# RUN bundle install
# RUN bundle exec rake build

# ─────────────────────────────────────────────────────────────────────────────┘

# ADD docker/entrypoint.sh /usr/local/bin/docker_entrypoint.sh
# RUN chmod +x /usr/local/bin/docker_entrypoint.sh
#
# ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]

CMD ["/bin/bash"]
