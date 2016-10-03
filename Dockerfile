FROM alpine:latest
ENV HOME /root

MAINTAINER Alessandro Molari <molari.alessandro@gmail.com> (alem0lars)

# ────────────────────────────────────────────── Setup basic system packages ──┐
RUN apk update \
 && apk upgrade

# Install common libraries.
RUN apk add --update --no-cache                                                \
    curl-dev                                                                   \
    db-dev                                                                     \
    geoip-dev                                                                  \
    glib-dev                                                                   \
    krb5-dev                                                                   \
    libevent-dev                                                               \
    libffi-dev                                                                 \
    libbz2                                                                     \
    libxml2-dev                                                                \
    libxslt-dev                                                                \
    libssl1.0                                                                  \
    libtool                                                                    \
    libwebp-dev                                                                \
    libjpeg-turbo-dev                                                          \
    libpng-dev                                                                 \
    libpq                                                                      \
    linux-headers                                                              \
    ncurses                                                                    \
    ncurses-dev                                                                \
    readline-dev                                                               \
    sqlite-dev                                                                 \
    yaml-dev

# Install basic packages.
RUN apk add --update --no-cache                                                \
    autoconf                                                                   \
    automake                                                                   \
    ca-certificates                                                            \
    curl                                                                       \
    file                                                                       \
    g++                                                                        \
    gcc                                                                        \
    make                                                                       \
    tar                                                                        \
    vim                                                                        \
    xz                                                                         \
    zsh
# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────── Setup ruby (1) ──┐
ENV RUBY_MAJOR=2.3                                                             \
    RUBY_VERSION=2.3.1                                                         \
    RUBY_DOWNLOAD_SHA1=c39b4001f7acb4e334cb60a0f4df72d434bef711                \
    RUBYGEMS_VERSION=2.6.6

ENV BUNDLER_VERSION 1.12.5

# Install ruby dependencies.
RUN apk add --update --no-cache                                                \
    bison                                                                      \
    gdbm-dev

# Install ruby.
RUN set -ex                                                                    \
 && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)                 \
 && curl -fSL -o ruby.tar.gz                                                   \
    "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz"\
 && echo "$RUBY_DOWNLOAD_SHA1 *ruby.tar.gz" | sha1sum -c -                     \
 && mkdir -p /usr/src/ruby                                                     \
 && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1                 \
 && rm ruby.tar.gz                                                             \
 && cd /usr/src/ruby                                                           \
 && { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new     \
 && mv file.c.new file.c                                                       \
 && autoconf                                                                   \
 && ./configure --disable-install-doc                                          \
 && make -j"${NPROC}"                                                          \
 && make install                                                               \
 && gem update --system $RUBYGEMS_VERSION                                      \
 && rm -r /usr/src/ruby

# Install things globally and don't create `.bundle` in all our apps.
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="${GEM_HOME}"                                                  \
    BUNDLE_BIN="${GEM_HOME}/bin"                                               \
    BUNDLE_SILENCE_ROOT_WARNING=1                                              \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p  "${GEM_HOME}" "${BUNDLE_BIN}"                                    \
 && chmod 777 "${GEM_HOME}" "${BUNDLE_BIN}"

# Install bundler.
RUN gem install bundler --version "${BUNDLER_VERSION}"
# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup ssh ──┐
# Install ssh daemon.
RUN apk add --update --no-cache                                                \
    openssh
# Generate fresh keys.
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa                       \
 && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
# Prepare ssh run directory.
RUN mkdir -p /var/run/sshd
# Expose ssh port.
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
# ─────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────────────────────────── Setup fizzy ──┐
# Install fizzy dependencies.
RUN gem install thor
RUN apk add --update --no-cache                                                \
    sudo
# Install fizzy.
RUN curl -sL                                                                   \
    https://raw.githubusercontent.com/alem0lars/fizzy/master/build/fizzy       \
  | tee /usr/local/bin/fizzy > /dev/null                                       \
 && chmod +x /usr/local/bin/fizzy
# ─────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────── Setup ruby (2) ──┐
# Configure ruby.
RUN fizzy cfg s -C ruby -U https:alem0lars/configs-ruby                        \
 && fizzy qi -V docker-test-box -C ruby -I ruby
# ─────────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────── Setup app ──┐
ENV APP_DIR="${HOME}/fizzy"
# ──────────────────────────── (trick to allow caching) Install dependencies ──┤
WORKDIR /tmp
COPY ./Gemfile      Gemfile
COPY ./Gemfile.lock Gemfile.lock
RUN bundle install
RUN rm ./Gemfile                                                               \
 && rm ./Gemfile.lock
# ────────────────────────────────────────────────────────────── Add the app ──┤
COPY .  "${APP_DIR}"
WORKDIR "${APP_DIR}"
RUN bundle install
RUN bundle exec rake build
# ─────────────────────────────────────────────────────────────────────────────┘

COPY docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod +x /usr/local/bin/docker_entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
