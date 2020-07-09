# mikenye/postfix

Postfix is Wietse Venema's excellent mail server.

This container attempts to simplify and streamline setting up inbound and outbound mail relays, to protect and enhance self hosted email servers (eg: Microsoft Exchange). However, if you find an alternate use, please let me know so I can add to "Deployment Recipes".

The container employs Postfix's [Postscreen](http://www.postfix.org/POSTSCREEN_README.html) for enhanced protection.

Apart from basic email relaying, the container can optionally:

* Implement up-to-date [TLS/SSL security for SMTP connections](http://www.postfix.org/TLS_README.html)
* Perform email virus scanning with [ClamAV](https://www.clamav.net) for all inbound/outbound email
* Implement [DNSBL](https://en.wikipedia.org/wiki/Domain_Name_System-based_Blackhole_List)s for inbound email
* Perform [DKIM](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail) signing for all outbound email
* Perform [DKIM](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail) verification for all inbound email
* Implement [spf](https://en.wikipedia.org/wiki/Sender_Policy_Framework) checking for inbound email
* Implement [greylisting](https://en.wikipedia.org/wiki/Greylisting_(email)) for inbound email
* Implement LDAP-based recipient verification for inbound email

The container is fully configured via environment variables - each service's configuration files built from environment variables on container start. It also supports some configuration files via volume mappings.

Currently supported docker architectures are `linux/386`, `linux/amd64`, `linux/arm/v7` and `linux/arm64`.

---

**Please note - docker hub cuts off this readme as it is quite long. To view the full readme [click here](https://github.com/mikenye/docker-postfix/blob/master/README.md).**

---

## Services

This container implement's the excellent [s6-overlay](https://github.com/just-containers/s6-overlay) for process supervision (and a bunch of other handy stuff).

| Service Name | Description | When is it started |
|-----|-----|-----|
| `postfix` | Runs postfix | Always |
| `clamav-milter` | Part of ClamAV. Runs the `clamav-milter` for scanning emails for virii. | If `ENABLE_CLAMAV` is set to `true` |
| `clamd` | Part of ClamAV. Runs `clamd`, the virus scanning engine for `clamav-milter`. |  If `ENABLE_CLAMAV` is set to `true` |
| `freshclam` | Part of ClamAV. Runs `freshclam` on the schedule defined by `FRESHCLAM_CHECKS_PER_DAY` to keep the ClamAV database updated. | If `ENABLE_CLAMAV` is set to `true` |
| `opendkim` | Runs `opendkim` for DKIM signing/verification. | If `ENABLE_OPENDKIM` is set to `true` |
| `postgrey` | Runs `postgrey` for greylisting. | If `ENABLE_POSTGREY` is set to `true` |
| `postgrey_whitelist_update` | Runs daily. Fetches the latest system whitelist from <https://postgrey.schweikert.ch/pub/postgrey_whitelist_clients>, merges with any locally defined whitelist, and reloads `postgrey`. | If `ENABLE_POSTGREY` is set to `true` |
| `syslogd` | Present for `opendkim` and `postgrey` logging. | Always |

## Deployment Recipes

### Wrap a Local Exchange Server

![Wrapping an Exchange Server](https://github.com/mikenye/docker-postfix/blob/dev/deployment_recipe_wrap_exchange.png?raw=true)

In this deployment recipe, two containers (`mail_in` and `mail_out`) are created.

`mail_in` is designed to sit between the internet and a local legacy Exchange server. It handles inbound email, and provides the following:

* Uses `postscreen` to ensure the sending MTA is standards compliant
* Uses DNSBLs as an initial anti-spam measure
* Provides up-to-date TLS for incoming clients
* Performs greylisting as another anti-spam measure
* Performs SPF & DKIM verification
* Performs various header/sender/recipient checks to make sure the message is valid
* Performs recipient verification via LDAP to internal Active Directory
* Scans the email for viruses with ClamAV
* Forwards the email to the legacy Exchange server

`mail_out` is designed to sit between the local legacy Exchange server and the internet. It handles outbound email, and provides the following:

* Provides up-to-date TLS for talking to external MTAs
* Performs DKIM signing
* Scans the email for viruses with ClamAV
* Delivers the outgoing email

From a networking perspective:

* The site's internet router is configured to NAT incoming connections on TCP port 25 through to the docker host running `mail_in` on port TCP 2525.
* The site's Exchange server is configured to send email (via "smart host") to the docker host (which is hard-coded to TCP port 25)

An example `docker-compose.yml` file is follows:

```yaml
version: '3.8'

volumes:
  queue_out:
    driver: local
  queue_in:
    driver: local
  certs:
    driver: local
  dkim:
    driver: local
  clamav_in:
    driver: local
  clamav_out:
    driver: local
  postgrey_in:
    driver: local
  tables_in:
    driver: local
  aliases_in:
    driver: local
  asupdata_in:
    driver: local
  logs_in:
    driver: local
  logs_out:
    driver: local

services:

  mail_out:
    image: mikenye/postfix
    container_name: mail_out
    restart: always
    logging:
      driver: "json-file"
      options:
        max-file: "10"
        max-size: "10m"
    ports:
      - "25:25"
    environment:
      TZ: "Australia/Perth"
      POSTMASTER_EMAIL: "postmaster@yourdomain.tld"
      POSTFIX_INET_PROTOCOLS: "ipv4"
      POSTFIX_MYORIGIN: "mail.yourdomain.tld"
      POSTFIX_PROXY_INTERFACES: "your.external.IP.address"
      POSTFIX_MYNETWORKS: "your.local.LAN.subnet/prefix"
      POSTFIX_MYDOMAIN: "yourdomain.tld"
      POSTFIX_MYHOSTNAME: "mail.yourdomain.tld"
      POSTFIX_MAIL_NAME: "outbound"
      POSTFIX_SMTPD_TLS_CHAIN_FILES: "/etc/postfix/certs/privkey.pem, /etc/postfix/certs/fullchain.pem"
      POSTFIX_SMTP_TLS_CHAIN_FILES: "/etc/postfix/certs/privkey.pem, /etc/postfix/certs/fullchain.pem"
      POSTFIX_SMTPD_TLS_SECURITY_LEVEL: "may"
      POSTFIX_SMTPD_TLS_LOGLEVEL: 1
      POSTFIX_REJECT_INVALID_HELO_HOSTNAME: "false"
      POSTFIX_REJECT_NON_FQDN_HELO_HOSTNAME: "false"
      POSTFIX_REJECT_UNKNOWN_HELO_HOSTNAME: "false"
      ENABLE_OPENDKIM: "true"
      OPENDKIM_SIGNINGTABLE: "/etc/mail/dkim/SigningTable"
      OPENDKIM_KEYTABLE: "/etc/mail/dkim/KeyTable"
      OPENDKIM_MODE: "s"
      OPENDKIM_INTERNALHOSTS: "your.local.LAN.subnet/prefix"
      OPENDKIM_LOGRESULTS: "true"
      OPENDKIM_LOGWHY: "true"
      ENABLE_CLAMAV: "true"
      CLAMAV_MILTER_REPORT_HOSTNAME: "mail.yourdomain.tld"
    volumes:
      - "certs:/etc/postfix/certs:ro"
      - "dkim:/etc/mail/dkim:rw"
      - "clamav_out:/var/lib/clamav:rw"
      - "queue_out:/var/spool/postfix:rw"
      - "logs_out:/var/log:rw"

  mail_in:
    image: mikenye/postfix
    container_name: mail_in
    restart: always
    logging:
      driver: "json-file"
      options:
        max-file: "10"
        max-size: "10m"
    dns:
      - 8.8.8.8
      - 8.8.4.4
    ports:
      - "2525:25"
    environment:
      TZ: "Australia/Perth"
      POSTMASTER_EMAIL: "postmaster@yourdomain.tld"
      POSTFIX_INET_PROTOCOLS: "ipv4"
      POSTFIX_MYORIGIN: "mail.yourdomain.tld"
      POSTFIX_PROXY_INTERFACES: "your.external.IP.address"
      POSTFIX_MYDOMAIN: "yourdomain.tld"
      POSTFIX_MYHOSTNAME: "mail.yourdomain.tld"
      POSTFIX_MAIL_NAME: "inbound"
      POSTFIX_SMTPD_TLS_CHAIN_FILES: "/etc/postfix/certs/privkey.pem, /etc/postfix/certs/fullchain.pem"
      POSTFIX_SMTP_TLS_CHAIN_FILES: "/etc/postfix/certs/privkey.pem, /etc/postfix/certs/fullchain.pem"
      POSTFIX_SMTPD_TLS_SECURITY_LEVEL: "may"
      POSTFIX_SMTPD_TLS_LOGLEVEL: 1
      POSTFIX_RELAYHOST: "exchange.server.IP.addr"
      POSTFIX_RELAY_DOMAINS: "yourdomain.tld,someotherdomain.tld"
      POSTFIX_DNSBL_SITES: "hostkarma.junkemailfilter.com=127.0.0.2, bl.spamcop.net, cbl.abuseat.org=127.0.0.2, zen.spamhaus.org"
      ENABLE_OPENDKIM: "true"
      OPENDKIM_MODE: "v"
      OPENDKIM_LOGRESULTS: "true"
      OPENDKIM_LOGWHY: "true"
      ENABLE_SPF: "true"
      ENABLE_CLAMAV: "true"
      CLAMAV_MILTER_REPORT_HOSTNAME: "mail.yourdomain.tld"
      ENABLE_POSTGREY: "true"
      ENABLE_LDAP_RECIPIENT_ACCESS: "true"
      POSTFIX_LDAP_SERVERS: "active.directory.server.IP,active.directory.server.IP"
      POSTFIX_LDAP_BIND_DN: "CN=mailrelay,OU=Service Accounts,OU=Users,DC=yourdomain,DC=tld"
      POSTFIX_LDAP_BIND_PW: "12345"
      POSTFIX_LDAP_SEARCH_BASE: "DC=yourdomain,DC=tld"
    volumes:
      - "certs:/etc/postfix/certs:ro"
      - "queue_in:/var/spool/postfix:rw"
      - "clamav_in:/var/lib/clamav:rw"
      - "postgrey_in:/etc/postgrey:ro"
      - "tables_in:/etc/postfix/tables:ro"
      - "aliases_in:/etc/postfix/local_aliases:ro"
      - "logs_in:/var/log:rw"
```

## Environment Variables

### Container configuration

| Environment Variable | Description                                                                               |
|----------------------|-------------------------------------------------------------------------------------------|
| `ENABLE_CLAMAV`      | Optional. Set to "true" to enable [ClamAV](https://www.clamav.net). Default is "false". |
| `ENABLE_LDAP_RECIPIENT_ACCESS` | Optional. Enable LDAP-based recipient verification. See **LDAP Recipient Verification** section below. |
| `ENABLE_OPENDKIM`    | Optional. Set to "true" to enable OpenDKIM. If OpenDKIM is enabled, the "OpenDKIM Configuration" variables below will need to be set. Default is "false". |
| `ENABLE_POSTGREY`    | Optional. Set to "true" to enable [postgrey](https://postgrey.schweikert.ch). Default is "false". |
| `ENABLE_SPF`         | Optional. Set to "true" to enable [policyd-spf](https://launchpad.net/postfix-policyd-spf-perl/). Default is "false". |
| `POSTMASTER_EMAIL`   | Required. Set to the email of your domain's postmaster. Example: `postmaster@domain.tld`. |
| `TZ`                 | Recommended. Set the timezone for the container. Default is `UTC`. |

### Postfix Configuration

| Environment Variable               | Documentation Link                                                      |
|------------------------------------|-------------------------------------------------------------------------|
| `POSTFIX_DNSBL_SITES`              | <http://www.postfix.org/postconf.5.html#postscreen_dnsbl_sites> |
| `POSTFIX_DNSBL_THRESHOLD`          | <http://www.postfix.org/postconf.5.html#postscreen_dnsbl_threshold> |
| `POSTFIX_INET_PROTOCOLS`           | <http://www.postfix.org/postconf.5.html#inet_protocols> |
| `POSTFIX_MAIL_NAME`                | <http://www.postfix.org/postconf.5.html#mail_name> |
| `POSTFIX_MESSAGE_SIZE_LIMIT` | <http://www.postfix.org/postconf.5.html#message_size_limit> |
| `POSTFIX_MYDOMAIN`                 | <http://www.postfix.org/postconf.5.html#mydomain> |
| `POSTFIX_MYHOSTNAME`               | <http://www.postfix.org/postconf.5.html#myhostname> |
| `POSTFIX_MYNETWORKS`               | <http://www.postfix.org/postconf.5.html#mynetworks> |
| `POSTFIX_MYORIGIN`                 | <http://www.postfix.org/postconf.5.html#myorigin> |
| `POSTFIX_PROXY_INTERFACES`         | <http://www.postfix.org/postconf.5.html#proxy_interfaces> |
| `POSTFIX_REJECT_INVALID_HELO_HOSTNAME`  | <http://www.postfix.org/postconf.5.html#reject_invalid_helo_hostname> |
| `POSTFIX_REJECT_NON_FQDN_HELO_HOSTNAME` | <http://www.postfix.org/postconf.5.html#reject_non_fqdn_helo_hostname> |
| `POSTFIX_REJECT_UNKNOWN_HELO_HOSTNAME`  | <http://www.postfix.org/postconf.5.html#reject_unknown_helo_hostname> |
| `POSTFIX_RELAY_DOMAINS`            | <http://www.postfix.org/postconf.5.html#relay_domains> |
| `POSTFIX_RELAYHOST_PORT`           | Optional port argument for `POSTFIX_RELAYHOST`. Default is `25` so only need to change if you're `relayhost` is running on a different port. |
| `POSTFIX_RELAYHOST`                | <http://www.postfix.org/postconf.5.html#relayhost> |
| `POSTFIX_SMTP_TLS_CHAIN_FILES`     | <http://www.postfix.org/postconf.5.html#smtp_tls_chain_files> |
| `POSTFIX_SMTPD_RECIPIENT_RESTRICTIONS_PERMIT_SASL_AUTHENTICATED` | Set to `true` to include in `smtpd_recipient_restrictions`. <http://www.postfix.org/postconf.5.html#permit_sasl_authenticated> |
| `POSTFIX_SMTPD_TLS_CERT_FILE`      | <http://www.postfix.org/postconf.5.html#smtpd_tls_cert_file> |
| `POSTFIX_SMTPD_TLS_CHAIN_FILES`    | <http://www.postfix.org/postconf.5.html#smtpd_tls_chain_files> |
| `POSTFIX_SMTPD_TLS_KEY_FILE`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_key_file> |
| `POSTFIX_SMTPD_TLS_LOGLEVEL`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_loglevel> |
| `POSTFIX_SMTPD_TLS_SECURITY_LEVEL` | <http://www.postfix.org/postconf.5.html#smtpd_tls_security_level> |
| `POSTFIX_SMTPD_USE_TLS`            | <http://www.postfix.org/postconf.5.html#smtpd_use_tls> |
| `POSTFIX_SMTPUTF8_ENABLE`          | <http://www.postfix.org/SMTPUTF8_README.html> |

#### LDAP Recipient Verification

See "LDAP" section below.

| Environment Variable               | Documentation Link                                                      |
|------------------------------------|-------------------------------------------------------------------------|
| `POSTFIX_LDAP_SERVERS`             | Required. Comma separated list of LDAP servers. |
| `POSTFIX_LDAP_VERSION`             | Optional. LDAP version. Default is `3` (which works with Active Directory). |
| `POSTFIX_LDAP_QUERY_FILTER`        | Optional. LDAP query filter to find user/group emails. Default is `(&(|(objectclass=person)(objectclass=group))(proxyAddresses=smtp:%s))` which will find all user and group email addresses in Active Directory. |
| `POSTFIX_LDAP_SEARCH_BASE`         | Required. The base DN in which to search for users/groups. eg: `DC=MyDomain,DC=tld`. |
| `POSTFIX_LDAP_BIND_DN`             | Required. The account name to use to bind to the LDAP servers, specified in LDAP syntax, eg: `CN=svc-mailrelay,OU=Service Accounts,OU=Users,DC=MyDomain,DC=tld`. |
| `POSTFIX_LDAP_BIND_PW`             | Required. The account password for the `POSTFIX_LDAP_BIND_DN` account. |
| `POSTFIX_LDAP_DEBUG_LEVEL`         | Optional. If you're having problems, you can set this to `1` or higher. |

### OpenDKIM Configuration

| Environment Variable               | Detail                                                                  |
|------------------------------------|-------------------------------------------------------------------------|
| `OPENDKIM_DOMAIN`                  | Comma separated list of domains whose mail should be signed by this filter. |
| `OPENDKIM_INTERNALHOSTS`           | Comma separated list of internal hosts whose mail should be signed rather than verified. |
| `OPENDKIM_KEYFILE`                 | Gives the location (within the container) of a PEM-formatted private key to be used for signing all messages. |
| `OPENDKIM_KEYTABLE`                | Path to a key table. You do not need to include `refile:`. Can be used instead of `OPENDKIM_KEYFILE` & `OPENDKIM_SELECTOR` for multiple domains. |
| `OPENDKIM_LOGRESULTS`              | Set to `true` for for logging of the results of evaluation of all signatures that were at least partly intact. |
| `OPENDKIM_LOGWHY`                  | Set to `true` for very detailed logging about the logic behind the filter’s decision to either sign a message or verify it. |
| `OPENDKIM_MODE`                    | Selects operating modes. The string is a concatenation of characters that indicate which mode(s) of operation are desired. Valid modes are s (signer) and v (verifier). The default is sv except in test mode (see the opendkim(8) man page) in which case the default is v. When signing mode is enabled, one of the following combinations must also be set: (a) Domain, KeyFile, Selector, no KeyTable, no SigningTable; (b) KeyTable, SigningTable, no Domain, no KeyFile, no Selector; (c) KeyTable, SetupPolicyScript, no Domain, no KeyFile, no Selector. |
| `OPENDKIM_SELECTOR`                | Set to the selector specified when creating the Key File. |
| `OPENDKIM_SIGNINGTABLE`            | Path to a signing table file. You do not need to include `refile:`. Can be used instead of `OPENDKIM_DOMAIN` for multiple domains. |
| `OPENDKIM_SUBDOMAINS`              | Set to `true` to sign subdomains of those listed by the Domain parameter as well as the actual domains. |

### ClamAV Configuration

| Environment Variable               | Detail                                                                  |
|------------------------------------|-------------------------------------------------------------------------|
| `FRESHCLAM_CHECKS_PER_DAY`         | Optional. Number of database checks per day. Default: `12` (every two hours). |
| `CLAMAV_MILTER_REPORT_HOSTNAME`    | Optional. The hostname ClamAV will report in the `X-Virus-Scanned` header. If unset, defaults to the container's hostname. |

## Configuration Files

The following files can be optionally configured.

### Postfix table files

If using postfix table files, it is recommened to place all files into a single directory, and map this directory through to the container at `/etc/postfix/tables`.

| Table File (with respect to container) | Format | If this file is present... | After modifying... |
|-----|-----|-----|-----|
| `/etc/postfix/tables/client_access.cidr` | [cidr](http://www.postfix.org/cidr_table.5.html) | It is automatically added to postfix's [`check_client_access`](http://www.postfix.org/postconf.5.html#check_client_access). | Run helper command `update_client_access` (see below) |
| `/etc/postfix/tables/dnsbl_reply.texthash` | [texthash](http://www.postfix.org/DATABASE_README.html#types) | It is automatically added to postfix's [`postscreen_dnsbl_reply_map`](http://www.postfix.org/postconf.5.html#postscreen_dnsbl_reply_map). | Run helper command `update_dnsbl_reply` (see below) |
| `/etc/postfix/tables/header_checks.pcre` | [pcre](http://www.postfix.org/pcre_table.5.html) | It is automatically added to postfix's [`header_checks`](http://www.postfix.org/postconf.5.html#header_checks). | Run helper command `update_header_checks` (see below) |
| `/etc/postfix/tables/helo_access.hash` | [hash](http://www.postfix.org/DATABASE_README.html#types) | It is automatically added to postfix's [`check_helo_access`](http://www.postfix.org/postconf.5.html#check_helo_access). | Run helper command `update_helo_access` (see below) |
| `/etc/postfix/tables/postscreen_access.cidr` | [cidr](http://www.postfix.org/cidr_table.5.html) | It is automatically added to postfix's ['postscreen_access_list'](http://www.postfix.org/postconf.5.html#postscreen_access_list) (after [`permit_mynetworks`](http://www.postfix.org/postconf.5.html#permit_mynetworks)). | Run helper command `update_postscreen_access` (see below) |
| `/etc/postfix/tables/sender_access.hash` | [hash](http://www.postfix.org/DATABASE_README.html#types) | It is automatically added to postfix's [`check_sender_access`](http://www.postfix.org/postconf.5.html#check_sender_access). | Run helper command `update_sender_access` (see below) |
| `/etc/postfix/tables/recipient_access.hash` | [hash](http://www.postfix.org/DATABASE_README.html#types) | It is automatically added to postfix's [`check_recipient_access`](http://www.postfix.org/postconf.5.html#check_recipient_access). | Run helper command `check_recipient_access` (see below) |

### Postgrey whitelist files

For the format of this file, see the [postgrey manpage](https://linux.die.net/man/8/postgrey).

| Configuration file (with respect to container) | If this file is present... | After modifying... |
|-----|-----|-----| 
| `/etc/postgrey/postgrey_whitelist_clients.local` | It is merged with the regularly updated [system whitelist](https://postgrey.schweikert.ch/pub/postgrey_whitelist_clients). | Run helper command `update_postgrey_whitelist` (see below). |

The system whitelist is downloaded from <https://postgrey.schweikert.ch/pub/postgrey_whitelist_clients> once every 24 hours if postgrey is enabled.

### Local Aliases

The format of this file is as-per the [`/etc/aliases`](https://linux.die.net/man/5/aliases.postfix) file.

| Configuration file (with respect to container) | If this file is present... | After modifying... |
|-----|-----|-----|
| `/etc/postfix/local_aliases/aliases` | It is merged with the system aliases file. | Run helper command `update_aliases` (see below). |

The system aliases file maps `postmaster`, `root`, `postfix` and `clamav` through to the address specified by `POSTMASTER_EMAIL`.

## Paths

### Required to be mapped

| Path | Access | Detail |
|------|--------|--------|
| `/var/spool/postfix` | `rw` | Required. Mail queue & postgrey database. |

### Optional

| Path | Access | Detail |
|------|--------|--------|
| `/var/lib/clamav` | `rw` | ClamAV anti-virus database. Map if using ClamAV. |
| `/etc/postfix/local_aliases` | `rw` | A file named `aliases` should be placed in this folder. The contents of this file will be added to the container's `/etc/aliases` at startup. Map if you need to add entries to `/etc/aliases`. |
| `/etc/postfix/certs` | `ro` | Postfix TLS chain files should be placed in here. Map if using SSL. |
| `/etc/postgrey` | `ro` | Postgrey local whitelists should be placed in here. Map if using postgrey. |
| `/etc/postfix/tables` | `ro` | Postfix's tables should be placed in here. Map if you need to use any of the **Supported table files** listed above. |
| `/etc/mail/dkim` | `rw` | DKIM private keys (and `KeyTable`/`SigningTable` files if used) to be placed here. |


## DKIM 

### Generating a DKIM key

When setting up DKIM, you can use this container to create your keys.

Change to a directory on the host that will hold the public & private keys.

```
cd /path/to/dkim/keys
```

Generate a key with the following command (replacing `your.domain.name` with your domain name):

```
docker run \
    --rm \
    -it \
    -v $(pwd):/workdir \
    --entrypoint opendkim-genkey \
    mikenye/postfix \
    --directory=/workdir \
    --bits=1024 \
    --selector=<selector> \
    --restrict \
    --domain=<yourdomain.tld>
```

There should now be two files in your current directory, `<selector>.private` and `<selector>.txt`. This directory should be mapped through to the container (I suggest at `/etc/mail/dkim`), and the full path of the `<selector>.private` file (with respect to the container's filesystem) should be passed to `OPENDKIM_KEYFILE`. The `<selector>` should be passed to `OPENDKIM_SELECTOR`.

If you have more than one domain to sign mail for, you can use `KeyTable` and `SigningTable` files.

The `<selector>.txt` files contain DNS records which should be added to `yourdomain.tld`'s DNS.

As for a selector name, an example may be: “sales-201309-1024”. This example indicates that it belongs to the “sales” email stream, is intended to be rotated into active duty in September 2013 and references a 1024-bit key ([reference](https://www.m3aawg.org/sites/default/files/m3aawg-dkim-key-rotation-bp-2019-03.pdf)).

For more information, see the OpenDKIM readme: <http://opendkim.org/opendkim-README>

## LDAP

With LDAP-based recipient verification:

* Before accepting email, when postfix receives an `RCPT TO`, it will query LDAP for the address given.
* If LDAP finds an email address in your directory, the message will be accepted.
* If LDAP does not find an email address in your directory, the message will be deferred (status code 450).

This is usually a good idea, because it saves resources on your internal mail server. For example, a client runs MS Exchange & Kaspersky Security for Mail Server. Kaspersky scans all mail that hits the Exchange server, regardless of whether or not there is a recipient for the email. This means that if mail is sent to a non-existent address, you have the overhead of:

* The postfix container processing & scanning the email
* Kaspersky scanning the email
* Exchange processing the email, generating a bounce message
* Exchange & postfix trying to deliver the bounce message

With recipient verification, the sender is given a deferral, and after some time they will get a bounce message.

If setting this up for the first time:

* It is suggested to check the container log (grep for `" 450 "`) occasionaly to make sure there are no accidental deferrals.
* If there are accidental referrals, or you have addresses that email should be accepted for that are not in your directory, you can add these to the `recipient_access.hash` file (see above). The next time the message delivery is attempted (because we are deferring, not rejecting), it should deliver properly.

See the [Postfix LDAP Howto](http://www.postfix.org/LDAP_README.html) for more information.

## Helper Commands

These commands can be executed in the context of the container, for example:

```
docker exec <container> <command>
```

| Command | Purpose |
|--------|---------|
| `postfix reload` | Performs a `postfix reload` (should be done if SSL certs are updated, etc). |

### Reloading Postfix's table files

If you edit one of postfix's table files, you must run the appropriate helper command below before the new version of the table file will be active.

| Command | Purpose |
|--------|---------|
| `update_aliases` | Rebuilds `/etc/aliases` within the container, and runs `newaliases`. |
| `update_client_access` | Rebuilds files used by `check_client_access`. |
| `update_dnsbl_reply` | Rebuilds files used by `postscreen_dnsbl_reply_map`. |
| `update_header_checks` | Rebuilds files used by `header_checks`. |
| `update_helo_access` | Rebuilds files used by `check_helo_access`. |
| `update_postgrey_whitelist` | Rebuilds files used by postgrey's `--whitelist-clients`. |
| `update_postscreen_access` | Rebuilds files used by `postscreen_access_list`. |
| `update_recipient_access` | Rebuilds files used by `check_recipient_access`. |
| `update_sender_access` | Rebuilds files used by `check_sender_access`. |

## Postfix's Order of Checks/Restrictions

* `postscreen_access_list`:
  1. `permit_mynetworks` - includes any networks set by the `POSTFIX_MYNETWORKS` environment variable 
  2. `cidr:/etc/postfix/postscreen_access.cidr` - includes any local entries added to `/etc/postfix/tables/postscreen_access.cidr`. If you are using [fail2ban](http://www.fail2ban.org/) or similar, this is the file you can add your banned IPs to.
  3. If `POSTFIX_DNSBL_SITES` is configured, postscreen performs DNSBL checks. 
* `smtpd_helo_restrictions`:
  1. `permit_mynetworks` - includes any networks set by the `POSTFIX_MYNETWORKS` environment variable
  2. `check_helo_access hash:/etc/postfix/helo_access.hash` - includes any local entries added to `/etc/postfix/tables/helo_access.hash`
  3. `reject_invalid_helo_hostname` - unless the environment variable `POSTFIX_REJECT_INVALID_HELO_HOSTNAME` is set to `false`
  4. `reject_non_fqdn_helo_hostname` - unless the environment variable `POSTFIX_REJECT_NON_FQDN_HELO_HOSTNAME` is set to `false`
  5. `reject_unknown_helo_hostname` - unless the environment variable `POSTFIX_REJECT_UNKNOWN_HELO_HOSTNAME` is set to `false`
* `smtpd_recipient_restrictions`:
  1. `permit_mynetworks` - includes any networks set by the `POSTFIX_MYNETWORKS` environment variable
  2. `check_client_access cidr:/etc/postfix/client_access.cidr` - includes any local entries added to `/etc/postfix/tables/client_access.cidr`
  3. `permit_sasl_authenticated` - see: <http://www.postfix.org/postconf.5.html#permit_sasl_authenticated>. This is placed below `check_client_access` so that malicious actors can be blocked via `client_access.cidr`
  4. `check_sender_access hash:/etc/postfix/sender_access.hash` - includes any local entries added to `/etc/postfix/tables/header_checks.pcre`
  5. `reject_unauth_destination` - see: <http://www.postfix.org/postconf.5.html#reject_unauth_destination>. This is placed above more "expensive" checks to prevent wasting resources for mail that's going to be rejected.
  6. If `ENABLE_SPF` is enabled, `check_policy_service unix:private/policy` - performs SPF checks.
  7. `reject_non_fqdn_recipient` - see: <http://www.postfix.org/postconf.5.html#reject_non_fqdn_recipient>.
  8. `reject_non_fqdn_sender` - see: <http://www.postfix.org/postconf.5.html#reject_non_fqdn_sender>.
  9. `reject_unknown_sender_domain` - see: <http://www.postfix.org/postconf.5.html#reject_unknown_sender_domain>.
  10. `reject_unknown_recipient_domain` - see: <http://www.postfix.org/postconf.5.html#reject_unknown_recipient_domain>.
  11. If `ENABLE_POSTGREY` is enabled, `check_policy_service inet:127.0.0.1:10023` - performs greylisting.
  12. If `ENABLE_LDAP_RECIPIENT_ACCESS` is enabled, and/or if `/etc/postfix/tables/recipient_access.hash` exists, `check_recipient_access ...` - performs recipient address verification using LDAP and/or the `recipient_acces.hash` file.
  13. Finally:
    * If `check_recipient_access` is used (see above), then: `defer`
    * Else: `permit`
* `smtpd_data_restrictions`:
  1. `reject_unauth_pipelining` - see: <http://www.postfix.org/postconf.5.html#reject_unauth_pipelining>
  2. `permit`

After a message is queued, it is passed through milters:

1. If `ENABLE_DKIM`, the email is sent through `opendkim`. The email is signed/verified by DKIM.
2. If `ENABLE_CLAMAV`, the email is sent through `clamav-milter`. The email is dropped if a virus is detected.

## Testing

To test your configuration, [an `expect` script is included in the GitHub Repo](https://github.com/mikenye/docker-postfix/blob/master/test_server.expect).

The script requires `telnet`.

The syntax of the file is as follows:

```
test_server.expect <mail_server> <port> <helo> <from> <to>
```

Where:

* `<mail_server>` is the IP/hostname of the mail server
* `<port>` is the port of the mail server
* `<helo>` is the FQDN to identify as
* `<from>` is the sender email
* `<to>` is the recipient email

An email will be sent from `<from>`, to `<to>` with the subject `Test email sent at <date/time>`.

`expect` is used to wait for the server to respond properly between commands, to prevent the session from being terminated due to Postfix's `reject_unauth_pipelining`.

When setting this container up, it is recommended to:

* For inbound mail relays, from an __external__ server:
  * Test normal operation - Test from an external email address, to an internal mail address.
  * Test to ensure no open relay - Test from an internal email address, to an external mail address.
* For outbound mail relays, from an __internal__ server (as your outbound mail relay should not be accessable outside your LAN):
  * Test normal operation - Test from an internal email address, to an external mail address.
* For testing SPF/DKIM - there are online tools available, such as <https://email-test.had.dnsops.gov> (remember that this service is rate limited, so don't accidentally get banned by testing too much). Furthermore, you can send an email to a gmail address and then take a look at the headers when (if) the message arrives. Google performs SPF/DKIM/DMARC on all email.

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-postfix/issues).

## References

* <http://www.postfix.org/documentation.html>: Postfix Documentation.
* <http://opendkim.org/opendkim-README>: OpenDKIM Readme.
* <https://www.skelleton.net/2015/03/21/how-to-eliminate-spam-and-protect-your-name-with-dmarc/>: A fantastic HOWTO (dated, but still very much relevant).
* <https://petervibert.com/wp/expect-smtp-script/>: plagiarized their expect script and made some modifications for the testing script.