# mikenye/postfix

This container is still under development.



## Environment Variables

### Container configuration

| Environment Variable | Description                                                                               |
|----------------------|-------------------------------------------------------------------------------------------|
| `POSTMASTER_EMAIL`   | Required. Set to the email of your domain's postmaster. Example: `postmaster@domain.tld`. |
| `ENABLE_OPENDKIM`    | Optional. Set to "true" to enable OpenDKIM. Default is "false". If OpenDKIM is enabled, the "OpenDKIM Configuration" variables below will need to be set. |
| `ENABLE_SPF`         | Optional. Set to "true" to enable policyd-spf. Default is "false". |
| `TZ`                 | Optional. Set the timezone for the container. Default is `UTC`. |

### Postfix Configuration

| Environment Variable               | Documentation Link                                                      |
|------------------------------------|-------------------------------------------------------------------------|
| `POSTFIX_INET_PROTOCOLS`           | <http://www.postfix.org/postconf.5.html#inet_protocols> |
| `POSTFIX_MAIL_NAME`                | <http://www.postfix.org/postconf.5.html#mail_name> |
| `POSTFIX_MYDOMAIN`                 | <http://www.postfix.org/postconf.5.html#mydomain> |
| `POSTFIX_MYHOSTNAME`               | <http://www.postfix.org/postconf.5.html#myhostname> |
| `POSTFIX_MYNETWORKS`               | <http://www.postfix.org/postconf.5.html#mynetworks> |
| `POSTFIX_MYORIGIN`                 | <http://www.postfix.org/postconf.5.html#myorigin> |
| `POSTFIX_PROXY_INTERFACES`         | <http://www.postfix.org/postconf.5.html#proxy_interfaces> |
| `POSTFIX_SMTP_TLS_CHAIN_FILES`     | <http://www.postfix.org/postconf.5.html#smtp_tls_chain_files> |
| `POSTFIX_SMTPD_TLS_CERT_FILE`      | <http://www.postfix.org/postconf.5.html#smtpd_tls_cert_file> |
| `POSTFIX_SMTPD_TLS_CHAIN_FILES`    | <http://www.postfix.org/postconf.5.html#smtpd_tls_chain_files> |
| `POSTFIX_SMTPD_TLS_KEY_FILE`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_key_file> |
| `POSTFIX_SMTPD_TLS_LOGLEVEL`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_loglevel> |
| `POSTFIX_SMTPD_TLS_SECURITY_LEVEL` | <http://www.postfix.org/postconf.5.html#smtpd_tls_security_level> |
| `POSTFIX_SMTPD_USE_TLS`            | <http://www.postfix.org/postconf.5.html#smtpd_use_tls> |
| `POSTFIX_RELAYHOST`                | <http://www.postfix.org/postconf.5.html#relayhost> |
| `POSTFIX_RELAY_DOMAINS`            | <http://www.postfix.org/postconf.5.html#relay_domains> |

### OpenDKIM Configuration

| Environment Variable               | Detail                                                                  |
|------------------------------------|-------------------------------------------------------------------------|
| `OPENDKIM_DOMAIN`                  | Comma separated list of domains whose mail should be signed by this filter. |
| `OPENDKIM_KEYFILE`                 | Gives the location (within the container) of a PEM-formatted private key to be used for signing all messages. |
| `OPENDKIM_MODE`                    | Selects operating modes. The string is a concatenation of characters that indicate which mode(s) of operation are desired. Valid modes are s (signer) and v (verifier). The default is sv except in test mode (see the opendkim(8) man page) in which case the default is v. When signing mode is enabled, one of the following combinations must also be set: (a) Domain, KeyFile, Selector, no KeyTable, no SigningTable; (b) KeyTable, SigningTable, no Domain, no KeyFile, no Selector; (c) KeyTable, SetupPolicyScript, no Domain, no KeyFile, no Selector. |
| `OPENDKIM_INTERNALHOSTS`           | Comma separated list of internal hosts whose mail should be signed rather than verified. |
| `OPENDKIM_SELECTOR`                | Set to the selector specified when creating the Key File. |
| `OPENDKIM_SUBDOMAINS`              | Set to `true` to sign subdomains of those listed by the Domain parameter as well as the actual domains. |

### SPF Configuration

| Environment Variable               | Detail                                                                  |
|------------------------------------|-------------------------------------------------------------------------|


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

## References

<https://www.skelleton.net/2015/03/21/how-to-eliminate-spam-and-protect-your-name-with-dmarc/>