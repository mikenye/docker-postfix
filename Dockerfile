FROM debian:stable-slim

ENV ENABLE_OPENDKIM="false" \
    POSTFIX_SOURCE_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz \
    POSTFIX_SIG_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz.gpg2 \
    WIETSE_PGP_KEY_URL=http://ftp.porcupine.org/mirrors/postfix-release/wietse.pgp \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    POSTFIX_POLICY_SPF_TIME_LIMIT=3600s

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
      perl \
      libperl-version-perl \
      libnetaddr-ip-perl \
      libmail-spf-perl \
      libsys-hostname-long-perl \
      libunix-syslog-perl \
      && \
    mkdir -p /src/postfix && \
    # Get postfix-policyd-spf-perl
    git clone git://git.launchpad.net/postfix-policyd-spf-perl /src/postfix-policyd-spf-perl && \
    cd /src/postfix-policyd-spf-perl && \
    export BRANCH_POSTFIX_POLICYD_SPF_PERL=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_POSTFIX_POLICYD_SPF_PERL} && \
    cp -v /src/postfix-policyd-spf-perl/postfix-policyd-spf-perl /usr/local/lib/policyd-spf-perl
    echo "postfix-policyd-spf-perl ${BRANCH_POSTFIX_POLICYD_SPF_PERL}" >> /VERSIONS
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
      && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \; && \
    echo "postfix $(postconf mail_version | cut -d "=" -f 2 | tr -d " ")" >> /VERSIONS && \
    cat /VERSIONS

COPY rootfs/ /

EXPOSE 25/tcp

ENTRYPOINT [ "/init" ]