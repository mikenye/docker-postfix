FROM debian:stable-slim

ENV ENABLE_OPENDKIM="false" \
    CLAMAV_DOWNLOAD_URL=https://www.clamav.net/downloads/production/clamav-0.102.3.tar.gz \
    CLAMAV_SIG_URL=https://www.clamav.net/downloads/production/clamav-0.102.3.tar.gz.sig \
    POSTFIX_SOURCE_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz \
    POSTFIX_SIG_URL=http://ftp.porcupine.org/mirrors/postfix-release/official/postfix-3.5.3.tar.gz.gpg2 \
    POSTGREY_SOURCE_URL=http://postgrey.schweikert.ch/pub/postgrey-latest.tar.gz \    
    WIETSE_PGP_KEY_URL=http://ftp.porcupine.org/mirrors/postfix-release/wietse.pgp \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2
    #POSTFIX_POLICY_SPF_TIME_LIMIT=3600s

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
      libperl-version-perl \
      libssl-dev \
      libssl1.1 \
      libsys-hostname-long-perl \
      libunix-syslog-perl \
      libxml2 \
      libxml2-dev \
      m4 \
      make \
      net-tools \
      netbase \
      opendkim \
      opendkim-tools \
      openssl \
      perl \
      procps \
      socat \
      zlib1g \
      zlib1g-dev \
      && \
    ldconfig && \
    # Download postgrey
    mkdir -p /src/postgrey && \
    curl --location --output /src/postgrey.tar.gz "${POSTGREY_SOURCE_URL}" && \
    # Extract postgrey
    tar xzf /src/postgrey.tar.gz -C /src/postgrey && \
    cd $(find /src/postgrey -maxdepth 1 -type d | tail -1) && \
    # Download clamav
    mkdir -p /src/clamav && \
    curl --location --output /src/clamav.tar.gz "${CLAMAV_DOWNLOAD_URL}" && \
    curl --location --output /src/clamav.tar.gz.sig "${CLAMAV_SIG_URL}" && \
    # Verify clamav download
    CLAMAV_RSA_KEY=$(gpg2 --verify /src/clamav.tar.gz.sig /src/clamav.tar.gz 2>&1 | grep "using RSA key" | tr -s " " | cut -d " " -f 5)  && \
    gpg2 --recv-keys "${CLAMAV_RSA_KEY}" && \
    gpg2 --verify /src/clamav.tar.gz.sig /src/clamav.tar.gz || exit 1 && \
    # Extract clamav download
    tar xzf /src/clamav.tar.gz -C /src/clamav && \
    cd $(find /src/clamav -maxdepth 1 -type d | tail -1) && \
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
    # Get postfix-policyd-spf-perl
    mkdir -p /src/postfix-policyd-spf-perl && \
    git clone git://git.launchpad.net/postfix-policyd-spf-perl /src/postfix-policyd-spf-perl && \
    cd /src/postfix-policyd-spf-perl && \
    export BRANCH_POSTFIX_POLICYD_SPF_PERL=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_POSTFIX_POLICYD_SPF_PERL} && \
    cp -v /src/postfix-policyd-spf-perl/postfix-policyd-spf-perl /usr/local/lib/policyd-spf-perl && \
    echo "postfix-policyd-spf-perl ${BRANCH_POSTFIX_POLICYD_SPF_PERL}" >> /VERSIONS && \
    # Get postfix source & signature & author key
    mkdir -p /src/postfix && \
    curl --location --output /src/postfix.tar.gz "${POSTFIX_SOURCE_URL}" && \
    curl --location --output /src/postfix.tar.gz.gpg2 "${POSTFIX_SIG_URL}" && \
    curl --location --output /src/wietse.pgp "${WIETSE_PGP_KEY_URL}" && \
    # Verify postfix download
    gpg2 --import /src/wietse.pgp && \
    gpg2 --verify /src/postfix.tar.gz.gpg2 /src/postfix.tar.gz || exit 1 && \
    # Extract postfix download
    tar xzf /src/postfix.tar.gz -C /src/postfix && \
    # Build postfix
    cd $(find /src/postfix -maxdepth 1 -type d | tail -1) && \
    make makefiles pie=yes shared=yes dynamicmaps=yes CCARGS="-DUSE_TLS" AUXLIBS="-lssl -lcrypto" && \
    make && \
    # Create users/groups
    groupadd --system postdrop && \
    useradd --groups postdrop --no-create-home --no-user-group --system postfix && \
    useradd --user-group --no-create-home --system --shell=/bin/false clamav && \
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
    curl --location -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Clean up
    apt-get remove -y \
      check \
      curl \
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
      libxml2-dev \
      m4 \
      make \
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