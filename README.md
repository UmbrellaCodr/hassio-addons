Home Assistant Add-ons

## Configuration

Add-on configuration:

```yaml
domains:
  - subdomain1.duckdns.org
  - subdomain2.duckdns.org
lets_encrypt:
  accept_terms: true
  account: email@foobar.us
  algo: ec-384
  certfile: fullchain.pem
  cert_domains:
    - "*.foobar.us"
  challenge_alias: subdomain1.duckdns.org
  keyfile: privkey.pem
seconds: 300
token: xxx-xxx-xxx-xxx-xxx
```
