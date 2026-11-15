# LG TV (Moonfin)

Stock webOS can't trust a custom CA, so Moonfin rejects `https://streaming.internal` (Caddy's internal CA). On a TV
rooted with webOS Homebrew Channel, the CA is added at boot.

## Root shell

- Homebrew Channel → Settings: SSH Server and Telnet on. SSH password login is refused, so add your public key over
  Telnet (`ncat --telnet <tv> 23`; Arch's `telnet` client is in `inetutils`) to `/home/root/.ssh/authorized_keys`
  (dir `700`, file `600`), then `ssh root@<tv>`.
- Telnet gives a passwordless root shell to the LAN: switch it off when not needed.

## Trusting the CA

Get the CA with `curl -o /home/root/caddy-root.crt http://proxy.home.arpa/certificate` and compare its fingerprint
(`openssl x509 -in caddy-root.crt -noout -fingerprint -sha256`) with the proxy's root before trusting it.

The root filesystem is read-only, so `/var/lib/webosbrew/init.d/50-custom-ca` (named without an extension:
`run-parts`, which runs the files here at boot, skips names with dots) rebuilds both trust stores from the firmware's
copies at every boot and bind-mounts them; the mounts also reach the apps' jails. The CA bundle serves curl/OpenSSL
and Moonfin's service; the NSS database serves the web engine:

```sh
#!/bin/sh
# CA bundle (curl, OpenSSL)
cat /etc/ssl/certs/ca-certificates.crt /home/root/caddy-root.crt > /tmp/ca-certificates.crt
mount --bind /tmp/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
# NSS database (the web engine)
cp -a /etc/pki/nssdb /tmp/nssdb
certutil -d sql:/tmp/nssdb -A -t "C,," -n "Caddy Local Authority" -i /home/root/caddy-root.crt
mount --bind /tmp/nssdb /etc/pki/nssdb
# The web engine reads the NSS database once at start, and starts before this script
systemctl restart webapp-mgr.service
```

- Check after a reboot: `certutil -d sql:/etc/pki/nssdb -L | grep Caddy` lists it with `C,,`.
- Don't re-run the script by hand: it would append the CA to the mounted bundle again.
- Without the restart, web engine requests fail with `net::ERR_CERT_AUTHORITY_INVALID` ("Failed to fetch" in
  Moonfin), while Moonfin's service still reaches Jellyfin.
- A firmware update can remove root, and with it the script.

## Seerr in Moonfin

Moonfin reaches Seerr through Jellyfin's Moonbase plugin; the TV only talks to Jellyfin.

- **Server:** the `jellyfin` role installs Moonbase (`jellyfin_plugins`) with Seerr at its LAN address (Jellyfin
  doesn't trust Caddy's CA); requests' ufw allows streaming on Seerr's port.
- **TV:** Settings → Account → Settings Sync: Moonbase on (only automatic when the TV first signs in after the
  plugin is installed); then Settings → Integrations → Seerr, sign in with the Jellyfin account.
