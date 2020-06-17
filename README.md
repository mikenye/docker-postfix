# mikenye/postfix

This container is still under development.

## Environment Variables

### For container configuration

| Environment Variable | Description                                                                              |
|----------------------|------------------------------------------------------------------------------------------|
| `POSTMASTER_EMAIL`   | Required. Set to the email of your domain's postmaster. Example: `postmaster@domain.tld` |

### For postfix configuration

| Environment Variable               | Documentation Link                                                      |
|------------------------------------|-------------------------------------------------------------------------|
| `POSTFIX_INET_PROTOCOLS`           | <http://www.postfix.org/postconf.5.html#inet_protocols> |
| `POSTFIX_MYNETWORKS`               | <http://www.postfix.org/postconf.5.html#mynetworks> |
| `POSTFIX_MYORIGIN`                 | <http://www.postfix.org/postconf.5.html#myorigin> |
| `POSTFIX_PROXY_INTERFACES`         | <http://www.postfix.org/postconf.5.html#proxy_interfaces> |
| `POSTFIX_MYDOMAIN`                 | <http://www.postfix.org/postconf.5.html#mydomain> |
| `POSTFIX_MYHOSTNAME`               | <http://www.postfix.org/postconf.5.html#myhostname> |
| `POSTFIX_MAIL_NAME`                | <http://www.postfix.org/postconf.5.html#mail_name> |
| `POSTFIX_SMTPD_TLS_CERT_FILE`      | <http://www.postfix.org/postconf.5.html#smtpd_tls_cert_file> |
| `POSTFIX_SMTPD_TLS_KEY_FILE`       | <http://www.postfix.org/postconf.5.html#smtpd_tls_key_file> |
| `POSTFIX_SMTPD_TLS_SECURITY_LEVEL` | <http://www.postfix.org/postconf.5.html#smtpd_tls_security_level> |
