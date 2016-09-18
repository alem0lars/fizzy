FROM phusion/baseimage:latest
ENV HOME /root

MAINTAINER Alessandro Molari <molari.alessandro@gmail.com> (alem0lars)

# ─────────────────────────────────────────────────────── Start dependencies ──┐
# Enable sshd.
RUN rm -f /etc/service/sshd/down                                               \
 && /etc/my_init.d/00_regen_ssh_host_keys.sh -f
# Use baseimage-docker's init system
CMD ["/sbin/my_init"]
# ─────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────────── Setup basic system packages ──┐
# Update repos and upgrade packages.
RUN apt-get -qq update                                                         \
 && apt-get -qq upgrade

# Install basic packages.
RUN apt-get install -qq -y --no-install-recommends                             \
		autoconf                                                                   \
		automake                                                                   \
		bzip2                                                                      \
    ca-certificates                                                            \
    curl                                                                       \
		file                                                                       \
		g++                                                                        \
		gcc                                                                        \
    libbz2-dev                                                                 \
		libc6-dev                                                                  \
		libcurl4-openssl-dev                                                       \
		libdb-dev                                                                  \
		libevent-dev                                                               \
		libffi-dev                                                                 \
		libgeoip-dev                                                               \
		libglib2.0-dev                                                             \
		libjpeg-dev                                                                \
		libkrb5-dev                                                                \
		liblzma-dev                                                                \
		libmagickcore-dev                                                          \
		libmagickwand-dev                                                          \
		libmysqlclient-dev                                                         \
		libncurses-dev                                                             \
		libpng-dev                                                                 \
		libpq-dev                                                                  \
		libreadline-dev                                                            \
		libsqlite3-dev                                                             \
		libssl-dev                                                                 \
		libtool                                                                    \
		libwebp-dev                                                                \
		libxml2-dev                                                                \
		libxslt-dev                                                                \
		libyaml-dev                                                                \
		make                                                                       \
    patch                                                                      \
    sharutils                                                                  \
    sudo                                                                       \
    xz-utils
# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────── Setup ruby (1) ──┐
ENV RUBY_MAJOR=2.3                                                             \
    RUBY_VERSION=2.3.1                                                         \
    RUBY_DOWNLOAD_SHA1=c39b4001f7acb4e334cb60a0f4df72d434bef711                \
    RUBYGEMS_VERSION=2.6.6

ENV BUNDLER_VERSION 1.12.5

# Install ruby dependencies.
RUN apt-get -qq install -y                                                     \
    bison                                                                      \
		libgdbm-dev

# Install ruby.
RUN set -ex                                                                    \
 && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
 && echo "$RUBY_DOWNLOAD_SHA1 *ruby.tar.gz" | sha1sum -c -                     \
 && mkdir -p /usr/src/ruby                                                     \
 && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1                 \
 && rm ruby.tar.gz                                                             \
 && cd /usr/src/ruby                                                           \
 && { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new     \
 && mv file.c.new file.c                                                       \
 && autoconf                                                                   \
 && ./configure --disable-install-doc                                          \
 && make -j"$(nproc)"                                                          \
 && make install                                                               \
 && gem update --system $RUBYGEMS_VERSION                                      \
 && rm -r /usr/src/ruby

# Install things globally and don't create `.bundle` in all our apps.
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME"                                                    \
    BUNDLE_BIN="$GEM_HOME/bin"                                                 \
    BUNDLE_SILENCE_ROOT_WARNING=1                                              \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p  "$GEM_HOME" "$BUNDLE_BIN"                                        \
 && chmod 777 "$GEM_HOME" "$BUNDLE_BIN"

 # Install bundler.
 RUN gem install bundler --version "$BUNDLER_VERSION"
# ─────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────────────────────────── Setup fizzy ──┐
# Install fizzy dependencies.
RUN gem install thor
# Install fizzy.
RUN curl -sL                                                                   \
    https://raw.githubusercontent.com/alem0lars/fizzy/master/build/fizzy       \
  | tee /usr/local/bin/fizzy > /dev/null                                       \
 && chmod +x /usr/local/bin/fizzy
# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────── Setup ruby (2) ──┐
# Configure ruby.
# TODO uncomment when `--no-ask` is implemented
# RUN fizzy cfg s -C ruby -U https:alem0lars/configs-ruby
# RUN fizzy qi -V docker-test-box -C ruby -I ruby
# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup ssh ──┐
# Enable the insecure key permanently.
# In clients you can then login to the docker container by running:
#   $ docker ps # find the container <ID>
#   $ docker inspect -f "{{ .NetworkSettings.IPAddress }}" <ID> # find the <IP>
#   $ curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/services/sshd/keys/insecure_key
#   $ chmod 600 insecure_key
#   $ ssh -i insecure_key root@<IP> # login to the container through ssh
RUN /usr/sbin/enable_insecure_key
# Allow to perform ssh from inside.
RUN mkdir -p "${HOME}/.ssh"                                                    \
 && curl -o "${HOME}/.ssh/id_rsa" -fSL "https://github.com/phusion/baseimage-docker/raw/master/image/services/sshd/keys/insecure_key" \
 && chmod 600 "${HOME}/.ssh/id_rsa"
# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup git ──┐
# Install git packages.
RUN apt-get -qq install                                                        \
    git-sh                                                                     \
    git
# Setup a git user and ssh.
RUN groupadd -g 987 git                                                        \
 && useradd -g git -u 987 -d /git -m -r -s /usr/bin/git-shell git
# Set a long random password to unlock the git user account.
RUN usermod -p                                                                 \
    `dd if=/dev/urandom bs=1 count=30 | uuencode -m - | head -2 | tail -1`     \
    git
# Remove the annoying `/etc/motd`.
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic
# Configure local git client.
# TODO: Replace with fizzy config (when `--no-ask` is implemented).
RUN git config --global push.default simple                                    \
 && git config --global user.name root                                         \
 && git config --global user.email root@localhost.localdomain
# ─────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────────────────────────────── Cleanup ──┐
RUN apt-get clean                                                              \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup app ──┐
ENV APP_DIR="${HOME}/fizzy"
# ──────────────────────────── (trick to allow caching) install dependencies ──┤
WORKDIR /tmp
ADD ./Gemfile      Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install
RUN rm ./Gemfile                                                               \
 && rm ./Gemfile.lock
# ────────────────────────────────────────────────────── add & build the app ──┤
ADD . "$APP_DIR"
WORKDIR "${APP_DIR}"
# Trigger bundler to use the right location.
RUN bundle install
RUN rake build
# ─────────────────────────────────────────────────────────────────────────────┘
