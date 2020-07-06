FROM debian:stable-slim

ENV ENABLE_OPENDKIM="false" \
    CLAMAV_CLAMDCONF_FILE="/usr/local/etc/clamd.conf" \
    CLAMAV_FRESHCLAMCONF_FILE="/usr/local/etc/freshclam.conf" \
    CLAMAV_MILTERCONF_FILE="/usr/local/etc/clamav-milter.conf" \
    POSTGREY_SOURCE_URL=http://postgrey.schweikert.ch/pub/postgrey-latest.tar.gz \
    POSTGREY_SYSTEM_WHITELIST_FILE=/opt/postgrey/postgrey_whitelist_clients \
    POSTGREY_WHITELIST_URL=https://postgrey.schweikert.ch/pub/postgrey_whitelist_clients \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    WIETSE_PGP_KEY_URL=http://ftp.porcupine.org/mirrors/postfix-release/wietse.pgp

SHELL ["/bin/bash", "-c"]

RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        2to3 \
        autoconf \
        automake \
        binutils \
        busybox-syslogd \
        ca-certificates \
        curl \
        file \
        g++ \
        gcc \
        git \
        gnupg2 \
        libberkeleydb-perl \
        libbz2-dev \
        libcurl4-openssl-dev \
        libdb5.3-dev \
        libjson-c3 \
        libjson-c-dev \
        libldap2-dev \
        libldap-2.4-2 \
        libldap-common \
        libmail-spf-perl \
        libmilter-dev \
        libmilter1.0.1 \
        libncurses5-dev \
        libnet-server-perl \
        libnetaddr-ip-perl \
        libpcre2-dev \
        libpcre2-8-0 \
        libpcre3-dev \
        libsasl2-dev \
        libsasl2-2 \
        libssl-dev \
        libsys-hostname-long-perl \
        libtool \
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
        pkg-config \
        procps \
        python3 \
        python3-distutils \
        python3-setuptools \
        socat \
        texinfo \
        xz-utils \
        zlib1g \
        zlib1g-dev \
        && \
    mkdir -p /etc/mail/dkim && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    # Create groups & users
    groupadd --system postdrop && \
    groupadd --system clamav && \
    groupadd --system postgrey && \
    useradd \
        --groups postdrop \
        --no-create-home \
        --no-user-group \
        --system \
        --shell=/usr/sbin/nologin \
        postfix \
        && \
    useradd \
        --groups clamav \
        --no-create-home \
        --no-user-group \
        --system \
        --shell=/usr/sbin/nologin \
        clamav \
        && \
    useradd \
        --groups postgrey \
        --no-create-home \
        --no-user-group \
        --system \
        --shell=/usr/sbin/nologin \
        postgrey \
        && \    
    # Install postgrey
    mkdir -p /src/postgrey && \
    curl --location --output /src/postgrey.tar.gz "${POSTGREY_SOURCE_URL}" && \
    tar xf /src/postgrey.tar.gz -C /src/postgrey && \
    pushd $(find /src/postgrey -maxdepth 1 -type d | tail -1) && \
    mkdir -p /opt/postgrey && \
    cp -Rv * /opt/postgrey && \
    mkdir -p /etc/postgrey && \
    touch /etc/postgrey/postgrey_whitelist_clients.local && \
    touch /etc/postgrey/postgrey_whitelist_recipients.local && \
    ln -s /opt/postgrey/postgrey /usr/local/bin/postgrey && \
    mkdir -p /var/spool/postfix/postgrey && \
    popd && \
    # Download & install libcheck (for clamav)
    mkdir -p /src/libcheck && \
    git clone https://github.com/libcheck/check.git /src/libcheck && \
    pushd /src/libcheck && \
    export BRANCH_LIBCHECK=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_LIBCHECK} && \
    autoreconf --install && \
    ./configure && \
    make && \
    make check && \
    make install && \
    popd && \
    # Install clamav
    mkdir -p /src/clamav && \
    CLAMAV_LATEST_STABLE_VERSION=$(curl https://www.clamav.net/downloads | tr -d "\r" | tr -d "\n" | grep -oP "The latest stable release is\s+(<strong>){0,1}[\d\.]+\s*(<\/strong>){0,1}" | grep -oP "[\d\.]+") && \
    curl --location --output /src/clamav.tar.gz "https://www.clamav.net/downloads/production/clamav-${CLAMAV_LATEST_STABLE_VERSION}.tar.gz" && \
    curl --location --output /src/clamav.tar.gz.sig "https://www.clamav.net/downloads/production/clamav-${CLAMAV_LATEST_STABLE_VERSION}.tar.gz.sig" && \
    CLAMAV_RSA_KEY=$(gpg2 --verify /src/clamav.tar.gz.sig /src/clamav.tar.gz 2>&1 | grep "using RSA key" | tr -s " " | cut -d " " -f 5)  && \
    gpg2 --recv-keys "${CLAMAV_RSA_KEY}" && \
    gpg2 --verify /src/clamav.tar.gz.sig /src/clamav.tar.gz || exit 1 && \
    tar xf /src/clamav.tar.gz -C /src/clamav && \
    pushd $(find /src/clamav -maxdepth 1 -type d | tail -1) && \
    ./configure \
      --enable-milter \
      --enable-clamdtop \
      --enable-clamsubmit \
      --enable-clamonacc \
      --enable-check \
      --enable-experimental \
      --enable-libjson \
      --enable-xml \
      --enable-pcre \
      && \
    make && \
    make check && \
    make install && \
    ldconfig && \
    mkdir -p /var/lib/clamav && \
    mkdir -p /run/freshclam && \
    mkdir -p /run/clamav-milter && \
    mkdir -p /run/clamd && \
    popd && \
    # Get postfix-policyd-spf-perl
    mkdir -p /src/postfix-policyd-spf-perl && \
    git clone git://git.launchpad.net/postfix-policyd-spf-perl /src/postfix-policyd-spf-perl && \
    pushd /src/postfix-policyd-spf-perl && \
    export BRANCH_POSTFIX_POLICYD_SPF_PERL=$(git tag --sort="-creatordate" | head -1) && \
    git checkout ${BRANCH_POSTFIX_POLICYD_SPF_PERL} && \
    cp -v /src/postfix-policyd-spf-perl/postfix-policyd-spf-perl /usr/local/lib/policyd-spf-perl && \
    popd && \
    # Get postfix source & signature & author key
    mkdir -p /src/postfix && \
    POSTFIX_STABLE_FAMILY=$(curl http://ftp.porcupine.org/mirrors/postfix-release/index.html | grep -oP "Postfix [\d.]+ stable release" | grep -v candidate | head -1 | grep -oP "[\d.]+") && \
    POSTFIX_STABLE_DOWNLOAD_SOURCE_FILE=$(curl http://ftp.porcupine.org/mirrors/postfix-release/index.html | grep -P '<a href="official/postfix-' | grep 3\.5 | grep '.tar.gz">Source code</a>' | head -1 | cut -d '"' -f 2) && \
    POSTFIX_STABLE_DOWNLOAD_SOURCE_GPG2=$(curl http://ftp.porcupine.org/mirrors/postfix-release/index.html | grep -P '<a href="official/postfix-' | grep 3\.5 | grep '.tar.gz.gpg2">GPG signature</a>' | head -1 | cut -d '"' -f 2) && \
    curl --location --output /src/postfix.tar.gz "http://ftp.porcupine.org/mirrors/postfix-release/${POSTFIX_STABLE_DOWNLOAD_SOURCE_FILE}" && \
    curl --location --output /src/postfix.tar.gz.gpg2 "http://ftp.porcupine.org/mirrors/postfix-release/${POSTFIX_STABLE_DOWNLOAD_SOURCE_GPG2}" && \
    curl --location --output /src/wietse.pgp "${WIETSE_PGP_KEY_URL}" && \
    gpg2 --import /src/wietse.pgp && \
    gpg2 --verify /src/postfix.tar.gz.gpg2 /src/postfix.tar.gz || exit 1 && \
    tar xf /src/postfix.tar.gz -C /src/postfix && \
    # Build postfix
    pushd $(find /src/postfix -maxdepth 1 -type d | tail -1) && \
    make \
      makefiles \
      pie=yes \
      shared=yes \
      dynamicmaps=yes \
      CCARGS="-DUSE_TLS \
              -DHAS_PCRE $(pcre-config --cflags) \
              -DHAS_LDAP \
              -I/usr/include/sasl \
              -DUSE_LDAP_SASL \
              " \
      AUXLIBS="-lssl -lcrypto -lsasl2" \
      AUXLIBS_PCRE="$(pcre-config --libs)" \
      AUXLIBS_LDAP="-lldap -llber" \
      && \
    make && \
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
    mkdir -p /etc/postfix/tables && \
    mkdir -p /etc/postfix/local_aliases && \
    popd && \
    # # Install fail2ban 
    # git clone https://github.com/fail2ban/fail2ban.git /src/fail2ban && \
    # pushd /src/fail2ban && \
    # FAIL2BAN_VERSION=$(git tag --sort="-creatordate" | head -1) && \
    # git checkout "${FAIL2BAN_VERSION}" && \
    # ./fail2ban-2to3 && \
    # ./fail2ban-testcases-all-python3 && \
    # python setup.py build && \
    # python setup.py install && \
    # popd && \
    # Install s6-overlay
    curl --location -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Clean up
    apt-get remove -y \
        2to3 \
        autoconf \
        automake \
        binutils \
        g++ \
        gcc \
        git \
        gnupg2 \
        libbz2-dev \
        libcurl4-openssl-dev \
        libdb5.3-dev \
        libjson-c-dev \
        libldap2-dev \
        libmilter-dev \
        libncurses5-dev \
        libpcre2-dev \
        libpcre3-dev \
        libsasl2-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        texinfo \
        xz-utils \
        zlib1g-dev \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \; && \
    # Document versions
    opendkim -V | grep OpenDKIM | sed "s/OpenDKIM Filter //g" >> /VERSIONS && \
    postgrey --version >> /VERSIONS && \
    echo "ClamAV $(clamconf --version | tr -s " " | cut -d " " -f 5)" >> /VERSIONS && \
    echo "postfix-policyd-spf-perl ${BRANCH_POSTFIX_POLICYD_SPF_PERL}" >> /VERSIONS && \
    echo "postfix $(postconf mail_version | cut -d "=" -f 2 | tr -d " ")" >> /VERSIONS && \
    # fail2ban-client --version >> /VERSIONS && \
    cat /VERSIONS

COPY rootfs/ /

EXPOSE 25/tcp

ENTRYPOINT [ "/init" ]
