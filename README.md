# mikenye/postfix

This container is still under development.



## Environment Variables

### Container configuration

| Environment Variable | Description                                                                               |
|----------------------|-------------------------------------------------------------------------------------------|
| `ENABLE_CLAMAV`      | Optional. Set to "true" to enable [ClamAV](https://www.clamav.net). Default is "false". |
| `ENABLE_OPENDKIM`    | Optional. Set to "true" to enable OpenDKIM. If OpenDKIM is enabled, the "OpenDKIM Configuration" variables below will need to be set. Default is "false". |
| `ENABLE_POSTGREY`    | Optional. Set to "true" to enable [postgrey](https://postgrey.schweikert.ch). Default is "false". |
| `ENABLE_RBL_CBL_ABUSEAT` | Optional. Set to "true" to enable [`cbl.abuseat.org`](https://www.abuseat.org). Adds `reject_rbl_client cbl.abuseat.org=127.0.0.2` to `smtpd_recipient_restrictions`. Should only be used for incoming mail. Default is "false". |
| `ENABLE_RBL_HOSTKARMA_JUNKEMAILFILTER` | Optional. Set to "true" to enable [`hostkarma.junkemailfilter.com`](http://wiki.junkemailfilter.com/index.php/Spam_DNS_Lists) blacklist. Adds `reject_rbl_client hostkarma.junkemailfilter.com=127.0.0.2` to `smtpd_recipient_restrictions`. Should only be used for incoming mail. Default is "false". |
| `ENABLE_RBL_SPAMCOP` | Optional. Set to "true" to enable [`bl.spamcop.net`](https://www.spamcop.net/bl.shtml). Adds `reject_rbl_client bl.spamcop.net` to `smtpd_recipient_restrictions`. Should only be used for incoming mail. Default is "false". |
| `ENABLE_RBL_SPAMHAUS_ZEN` | Optional. Set to "true" to enable [zen.spamhaus.org](https://www.spamhaus.org/zen/). Adds `reject_rbl_client zen.spamhaus.org` to `smtpd_recipient_restrictions`. Should only be used for incoming mail. Default is "false". |
| `ENABLE_SPF`         | Optional. Set to "true" to enable [policyd-spf](https://launchpad.net/postfix-policyd-spf-perl/). Default is "false". |
| `POSTMASTER_EMAIL`   | Required. Set to the email of your domain's postmaster. Example: `postmaster@domain.tld`. |
| `TZ`                 | Optional. Set the timezone for the container. Default is `UTC`. |

### Postfix Configuration

| Environment Variable               | Documentation Link                                                      |
|------------------------------------|-------------------------------------------------------------------------|
| `POSTFIX_HEADER_CHECKS`            | Set to `true` to include `header_checks = pcre:/etc/postfix/tables/header_checks`. Make sure you perform a volume mapping and that `header_checks` exists at `/etc/postfix/tables` within the container. <http://www.postfix.org/postconf.5.html#header_checks> |
| `POSTFIX_INET_PROTOCOLS`           | <http://www.postfix.org/postconf.5.html#inet_protocols> |
| `POSTFIX_MAIL_NAME`                | <http://www.postfix.org/postconf.5.html#mail_name> |
| `POSTFIX_MESSAGE_SIZE_LIMIT` | <http://www.postfix.org/postconf.5.html#message_size_limit> |
| `POSTFIX_MYDOMAIN`                 | <http://www.postfix.org/postconf.5.html#mydomain> |
| `POSTFIX_MYHOSTNAME`               | <http://www.postfix.org/postconf.5.html#myhostname> |
| `POSTFIX_MYNETWORKS`               | <http://www.postfix.org/postconf.5.html#mynetworks> |
| `POSTFIX_MYORIGIN`                 | <http://www.postfix.org/postconf.5.html#myorigin> |
| `POSTFIX_PROXY_INTERFACES`         | <http://www.postfix.org/postconf.5.html#proxy_interfaces> |
| `POSTFIX_RELAY_DOMAINS`            | <http://www.postfix.org/postconf.5.html#relay_domains> |
| `POSTFIX_RELAYHOST`                | <http://www.postfix.org/postconf.5.html#relayhost> |
| `POSTFIX_SMTP_TLS_CHAIN_FILES`     | <http://www.postfix.org/postconf.5.html#smtp_tls_chain_files> |
| `POSTFIX_SMTPD_HELO_RESTRICTIONS_CHECK_HELO_ACCESS` | Set to `true` to include `check_helo_access` in `smtpd_helo_restrictions`. Postfix will use `hash:/etc/postfix/tables/helo_access`, so make sure you perform a volume mapping and that `helo_access` exists at `/etc/postfix/tables` within the container. <http://www.postfix.org/postconf.5.html#check_helo_access> |
| `POSTFIX_SMTPD_RECIPIENT_RESTRICTIONS_CHECK_SENDER_ACCESS` | Set to `true` to include `check_sender_access` in `smtpd_recipient_restrictions`. Postfix will use `hash:/etc/postfix/tables/sender_access`, so make sure you perform a volume mapping and that `sender_access` exists at `/etc/postfix/tables` within the container. <http://www.postfix.org/postconf.5.html#check_sender_access> |
| `POSTFIX_SMTPD_RECIPIENT_RESTRICTIONS_PERMIT_SASL_AUTHENTICATED` | Set to `true` to include in `smtpd_recipient_restrictions`. <http://www.postfix.org/postconf.5.html#permit_sasl_authenticated> |
| `POSTFIX_SMTPD_TLS_CERT_FILE`      | <http://www.postfix.org/postconf.5.html#smtpd_tls_cert_file> |
| `POSTFIX_SMTPD_TLS_CHAIN_FILES`    | <http://www.postfix.org/postconf.5.html#smtpd_tls_chain_files> |
| `POSTFIX_SMTPD_TLS_KEY_FILE`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_key_file> |
| `POSTFIX_SMTPD_TLS_LOGLEVEL`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_loglevel> |
| `POSTFIX_SMTPD_TLS_SECURITY_LEVEL` | <http://www.postfix.org/postconf.5.html#smtpd_tls_security_level> |
| `POSTFIX_SMTPD_USE_TLS`            | <http://www.postfix.org/postconf.5.html#smtpd_use_tls> |

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
| `FRESHCLAM_CHECKS_PER_DAY`         | Optional. Number of database checks per day. Default: 12 (every two hours). |
| `CLAMAV_MILTER_REPORT_HOSTNAME`    | Optional. The hostname ClamAV will report in the `X-Virus-Scanned` header. If unset, defaults to the container's hostname. |

## Paths

### Required to be mapped

| Path | Access | Detail |
|------|--------|--------|
| `/var/spool/postfix` | `rw` | Required. Mail queue & postgrey database. |

### Optional

| Path | Access | Detail |
|------|--------|--------|
| `/var/lib/clamav` | `rw` | ClamAV anti-virus database. Recommended to map if using ClamAV. |
| `/etc/postfix/local_aliases` | `rw` | A file named `aliases` should be placed in this folder. The contents of this file will be added to the container's `/etc/aliases` at startup. |
| `/etc/postfix/certs` | `ro` | Postfix TLS chain files should be placed in here. |
| `/etc/postgrey` | `ro` | Postgrey local whitelists should be placed in here. |
| `/etc/postfix/tables` | `rw` | Postfix's tables should be placed in here. |

## Generating a DKIM key

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
    --domain=<your.domain.name>
```

There should now be two files in your current directory, `<selector>.private` and `<selector>.txt`. This directory should be mapped through to the container, and the full path of the `<selector>.private` file (with respect to the container's filesystem) should be passed to `OPENDKIM_KEYFILE`. The `<selector>` should be passed to `OPENDKIM_SELECTOR`.

As for a selector name, an example may be: “sales-201309-1024”. This example indicates that it belongs to the “sales” email stream, is intended to be rotated into active duty in September 2013 and references a 1024-bit key ([reference](https://www.m3aawg.org/sites/default/files/m3aawg-dkim-key-rotation-bp-2019-03.pdf)).

## Helper scripts

| Script | Purpose |
|--------|---------|
| `docker exec <container> postmap_reload` | Performs a `postmap` on `/etc/postfix/tables/helo_access` & `/etc/postfix/tables/sender_access`, then performs a `postfix reload`. |

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

`expect` is used to wait for the server to respond properly between commands, to prevent the session from ending due to Postfix's `reject_unauth_pipelining`.


## References

* <https://www.skelleton.net/2015/03/21/how-to-eliminate-spam-and-protect-your-name-with-dmarc/>
* <https://petervibert.com/wp/expect-smtp-script/>: plagiarized their expect script and made some modifications for the testing script.