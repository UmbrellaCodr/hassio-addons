# Home Assistant Add-on: DuckDNS +acme.sh

Stay tuned! will update soon.

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Click the 3-dots menu at upper right ... > Repositories and add this repository's URL: [https://github.com/UmbrellaCodr/hassio-addons](https://github.com/UmbrellaCodr/hassio-addons) Find the "DuckDNS +acme.sh" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. Visit [DuckDNS.org](https://www.duckdns.org/) and create an account by logging in through any of the available account services (Google, Github, Twitter, Persona, Reddit).
2. In the `Domains` section, type the name of the subdomain you wish to register and click `add domain`.
3. If registration was a success, the subdomain is listed in the `Domains` section along with `current ip` being the public IP address of the device you are currently using to access `duckdns.org`. The IP address will be updated by the DuckDNS add-on.
4. In the DuckDNS add-on configuration, perform the following:

   - Copy the DuckDNS token (listed at the top of the page where account details are displayed) from `duckdns.org` and paste into the `token` option.
   - Update the `domains` option with the full domain name you registered. E.g., `my-domain.duckdns.org`.

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

TODO: for now don't add more then 1 domain to cert_domains; this is a known issue with DuckDNS and text records

Additionally, you'll need to configure the Home Assistant Core to pick up the SSL certificates. This is done by setting the following configuration for the [HTTP][http] integration configuration in your `configuration.yaml`:

```yaml
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
```
