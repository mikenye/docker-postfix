# mikenye/postfix

This container is still under development.

## Environment Variables

### For container configuration

| Environment Variable | Description                                                                              |
|----------------------|------------------------------------------------------------------------------------------|
| `POSTMASTER_EMAIL`   | Required. Set to the email of your domain's postmaster. Example: `postmaster@domain.tld` |

### For postfix configuration

| Environment Variable       | Documentation Link                                                      |
|----------------------------|-------------------------------------------------------------------------|
| `POSTFIX_INET_PROTOCOLS`   | <http://www.postfix.org/postconf.5.html#inet_protocols> |
| `POSTFIX_MYNETWORKS`       | <http://www.postfix.org/postconf.5.html#mynetworks> |
| `POSTFIX_MYORIGIN`         | <http://www.postfix.org/postconf.5.html#myorigin> |
| `POSTFIX_PROXY_INTERFACES` | <http://www.postfix.org/postconf.5.html#proxy_interfaces> |