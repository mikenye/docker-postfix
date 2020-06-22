FROM debian:stable-slim

ENV ENABLE_OPENDKIM="false" \
    POSTFIX_SOURCE_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz \
    POSTFIX_SIG_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz.gpg2 \
    WIETSE_PGP_KEY_URL=http://ftp.porcupine.org/mirrors/postfix-release/wietse.pgp \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      gcc \
      git \
      gnupg2 \
      libc6-dev \
      libdb5.3-dev \
      libssl-dev \
      libssl1.1 \
      m4 \
      make \
      net-tools \
      netbase \
      opendkim \
      opendkim-tools \
      openssl \
      procps \
      python3 \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      python3-dev \
      libmilter-dev \
      && \
    mkdir -p /src/postfix && \
    # Get spf-engine & prereqs
    pip3 install \
      pyspf \
      dnspython \
      authres \
      pymilter \
      && \
    git clone https://git.launchpad.net/spf-engine /src/spf-engine && \
    cd /src/spf-engine && \
    export BRANCH_SPF_ENGINE=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_SPF_ENGINE} && \
    echo "spf-engine ${BRANCH_SPF_ENGINE}" >> /VERSIONS && \
    # Fix https://bugs.launchpad.net/spf-engine/+bug/1856391
    sed -i '/from spf_engine.util import own_socketfile/d' spf_engine/milter_spf.py && \
    # Install spf-engine
    python3 setup.py install -O2 --single-version-externally-managed --record=/tmp/spf-engine.record && \
    mkdir -p /run/pyspf-milter && \
    adduser --system --no-create-home --quiet --disabled-password \
      --disabled-login --shell /bin/false --group \
      --home /run/pyspf-milter pyspf-milter && \
    # Get postfix source & signature & author key
    curl --output /src/postfix.tar.gz "${POSTFIX_SOURCE_URL}" && \
    curl --output /src/postfix.tar.gz.gpg2 "${POSTFIX_SIG_URL}" && \
    curl --output /src/wietse.pgp "${WIETSE_PGP_KEY_URL}" && \
    # Verify postfix download
    gpg2 --import /src/wietse.pgp && \
    gpg2 --verify /src/postfix.tar.gz.gpg2 /src/postfix.tar.gz || exit 1 && \
    # Extract postfix download
    tar xzf /src/postfix.tar.gz -C /src/postfix && \
    # Build postfix
    cd $(find /src/postfix -maxdepth 1 -type d | tail -1) && \
    make makefiles pie=yes shared=yes dynamicmaps=yes CCARGS="-DUSE_TLS" AUXLIBS="-lssl -lcrypto" && \
    make && \
    # Create user/group
    groupadd --system postdrop && \
    useradd --groups postdrop --no-create-home --no-user-group --system postfix && \
    # Install postfix
    POSTFIX_INSTALL_OPTS="" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} -non-interactive" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} install_root=/" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} tempdir=/tmp" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} config_directory=/etc/postfix" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} data_directory=/var/lib/postfix" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} daemon_directory=/usr/libexec/postfix" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} command_directory=/usr/sbin" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} html_directory=/opt/postfix_html" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} queue_directory=/var/spool/postfix" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} sendmail_path=/usr/sbin/sendmail" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} newaliases_path=/usr/sbin/newaliases" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} mailq_path=/usr/sbin/mailq" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} mail_owner=postfix" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} setgid_group=postdrop" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} manpage_directory=/usr/share/man" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} meta_directory=/etc/postfix" && \
    POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS} readme_directory=/opt/postfix_readme" && \
    make install POSTFIX_INSTALL_OPTS="${POSTFIX_INSTALL_OPTS}" && \
    # Install s6-overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Clean up
    apt-get remove -y \
      curl \
      file \
      gcc \
      git \
      gnupg2 \
      libc6-dev \
      libdb5.3-dev \
      libssl-dev \
      m4 \
      make \
      python3-dev \
      && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \; && \
    postconf mail_version

COPY rootfs/ /

EXPOSE 25/tcp

ENTRYPOINT [ "/init" ]