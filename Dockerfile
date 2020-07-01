FROM debian:stable-slim

ENV ENABLE_OPENDKIM="false" \
    CLAMAV_DOWNLOAD_URL=https://www.clamav.net/downloads/production/clamav-0.102.3.tar.gz \
    CLAMAV_SIG_URL=https://www.clamav.net/downloads/production/clamav-0.102.3.tar.gz.sig \
    POSTFIX_SOURCE_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz \
    POSTFIX_SIG_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz.gpg2 \
    POSTGREY_SOURCE_URL=http://postgrey.schweikert.ch/pub/postgrey-latest.tar.gz \
    POSTGREY_WHITELIST_URL=https://postgrey.schweikert.ch/pub/postgrey_whitelist_clients \
    POSTGREY_SYSTEM_WHITELIST_FILE=/opt/postgrey/postgrey_whitelist_clients \
    WIETSE_PGP_KEY_URL=http://ftp.porcupine.org/mirrors/postfix-release/wietse.pgp \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2
    #POSTFIX_POLICY_SPF_TIME_LIMIT=3600s

SHELL ["/bin/bash", "-c"]

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      busybox-syslogd \
      ca-certificates \
      check \
      curl \
      file \
      g++ \
      gcc \
      git \
      gnupg2 \
      libberkeleydb-perl \
      libbz2-1.0 \
      libbz2-dev \
      libc6-dev \
      libcurl4 \
      libcurl4-openssl-dev \
      libdb5.3-dev \
      libjson-c-dev \
      libjson-c3 \
      libmail-spf-perl \
      libmilter-dev \
      libmilter1.0.1 \
      libncurses5 \
      libncurses5-dev \
      libnet-server-perl \
      libnetaddr-ip-perl \
      libpcre2-16-0 \
      libpcre2-32-0 \
      libpcre2-8-0 \
      libpcre2-dev \
      libpcre2-posix0 \
      libpcre3-dev \
      libperl-version-perl \
      libssl-dev \
      libssl1.1 \
      libsys-hostname-long-perl \
      libunix-syslog-perl \
      libwrap0 \
      libwrap0-dev \
      libxml2 \
      libxml2-dev \
      m4 \
      make \
      net-tools \
      netbase \
      opendkim \
      opendkim-tools \
      openssl \
      pcre2-utils \
      perl \
      procps \
      python3 \
      python3-distutils \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      socat \
      zlib1g \
      zlib1g-dev \
      && \
    ldconfig && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

    # Download postgrey
RUN mkdir -p /src/postgrey && \
    curl --location --output /src/postgrey.tar.gz "${POSTGREY_SOURCE_URL}" && \
    # Extract postgrey
    tar xzf /src/postgrey.tar.gz -C /src/postgrey && \
    pushd $(find /src/postgrey -maxdepth 1 -type d | tail -1) && \
    # Install postgrey
    mkdir -p /opt/postgrey && \
    cp -Rv * /opt/postgrey && \
    mkdir -p /etc/postgrey && \
    touch /etc/postgrey/postgrey_whitelist_clients.local && \
    touch /etc/postgrey/postgrey_whitelist_recipients.local && \
    ln -s /opt/postgrey/postgrey /usr/local/bin/postgrey && \
    mkdir -p /var/spool/postfix/postgrey && \
    postgrey --version >> /VERSIONS && \
    popd

    # Download clamav
RUN mkdir -p /src/clamav && \
    curl --location --output /src/clamav.tar.gz "${CLAMAV_DOWNLOAD_URL}" && \
    curl --location --output /src/clamav.tar.gz.sig "${CLAMAV_SIG_URL}" && \
    # Verify clamav download
    CLAMAV_RSA_KEY=$(gpg2 --verify /src/clamav.tar.gz.sig /src/clamav.tar.gz 2>&1 | grep "using RSA key" | tr -s " " | cut -d " " -f 5)  && \
    gpg2 --recv-keys "${CLAMAV_RSA_KEY}" && \
    gpg2 --verify /src/clamav.tar.gz.sig /src/clamav.tar.gz || exit 1 && \
    # Extract clamav download
    tar xzf /src/clamav.tar.gz -C /src/clamav && \
    pushd $(find /src/clamav -maxdepth 1 -type d | tail -1) && \
    # Build clamav
    ./configure \
      --enable-milter \
      --enable-clamdtop \
      --enable-clamsubmit \
      --enable-clamonacc \
      && \
    make && \
    make check && \
    # Install clamav
    make install && \
    ldconfig && \
    mkdir -p /var/lib/clamav && \
    mkdir -p /run/freshclam && \
    mkdir -p /run/clamav-milter && \
    mkdir -p /run/clamd && \
    echo "ClamAV $(clamconf --version | tr -s " " | cut -d " " -f 5)" >> /VERSIONS && \
    popd

    # Get postfix-policyd-spf-perl
RUN mkdir -p /src/postfix-policyd-spf-perl && \
    git clone git://git.launchpad.net/postfix-policyd-spf-perl /src/postfix-policyd-spf-perl && \
    pushd /src/postfix-policyd-spf-perl && \
    export BRANCH_POSTFIX_POLICYD_SPF_PERL=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_POSTFIX_POLICYD_SPF_PERL} && \
    cp -v /src/postfix-policyd-spf-perl/postfix-policyd-spf-perl /usr/local/lib/policyd-spf-perl && \
    echo "postfix-policyd-spf-perl ${BRANCH_POSTFIX_POLICYD_SPF_PERL}" >> /VERSIONS && \
    popd

    # Get postfix source & signature & author key
RUN mkdir -p /src/postfix && \
    curl --location --output /src/postfix.tar.gz "${POSTFIX_SOURCE_URL}" && \
    curl --location --output /src/postfix.tar.gz.gpg2 "${POSTFIX_SIG_URL}" && \
    curl --location --output /src/wietse.pgp "${WIETSE_PGP_KEY_URL}" && \
    # Verify postfix download
    gpg2 --import /src/wietse.pgp && \
    gpg2 --verify /src/postfix.tar.gz.gpg2 /src/postfix.tar.gz || exit 1 && \
    # Extract postfix download
    tar xzf /src/postfix.tar.gz -C /src/postfix

    # Build postfix
RUN pushd $(find /src/postfix -maxdepth 1 -type d | tail -1) && \
    make \
      Makefile.init \
      makefiles \
      pie=yes \
      shared=yes \
      dynamicmaps=yes \
      CCARGS="-DUSE_TLS -DHAS_PCRE $(pcre-config --cflags)" \
      AUXLIBS="-lssl -lcrypto" \
      AUXLIBS_PCRE="$(pcre-config --libs)" \
      && \
    make && \
    # Create users/groups
    groupadd --system postdrop && \
    useradd --groups postdrop --no-create-home --no-user-group --system postfix && \
    useradd --user-group --no-create-home --system --shell=/bin/false clamav && \
    useradd --user-group --no-create-home --system --shell=/bin/false postgrey && \
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
    cp /etc/postfix/master.cf /etc/postfix/master.cf.original && \
    popd

    # Get fail2ban source
RUN git clone https://github.com/fail2ban/fail2ban.git /src/fail2ban && \
    pushd /src/fail2ban && \
    FAIL2BAN_VERSION=$(git tag --sort="-creatordate" | head -1) && \
    git checkout "${FAIL2BAN_VERSION}" && \
    # Fix fail2ban (see https://github.com/fail2ban/fail2ban/issues/1694)
    # Replace all instances of .iteritems() with .iter()
    sed "s/.iteritems()/.iter()/g" -i $(grep -Rl "\.iteritems()") && \
    # Build & install fail2ban
    python setup.py build && \
    python setup.py install && \
    fail2ban-server --version >> /VERSIONS && \
    popd

    # Make directories
RUN mkdir -p /etc/postfix/tables && \
    mkdir -p /etc/postfix/local_aliases && \
    mkdir -p /etc/mail/dkim && \
    # Install s6-overlay
    curl --location -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Clean up
    apt-get remove -y \
      check \
      file \
      g++ \
      gcc \
      git \
      gnupg2 \
      libbz2-dev \
      libc6-dev \
      libcurl4-openssl-dev \
      libdb5.3-dev \
      libjson-c-dev \
      libmilter-dev \
      libncurses5-dev \
      libpcre2-dev \
      libssl-dev \
      libwrap0-dev \
      libxml2-dev \
      m4 \
      make \
      python3-distutils \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      zlib1g-dev \
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
