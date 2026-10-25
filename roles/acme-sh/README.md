# acme.sh Role

Installs [`acme.sh`](https://github.com/acmesh-official/acme.sh) (git clone, not `curl | sh`) with its daily renewal
cron job. Domain-agnostic: certificates are issued by `acme-certificate`. Add it to the proxy host's play, like `caddy`.

## Notes

- Auto-upgrade (`acme.sh --upgrade --auto-upgrade`) is enabled at install only - the daily cron run upgrades
  acme.sh before renewing. On an existing install, run that command once by hand.
- Depends on `git`/`cron`/`openssl`/`curl` - runs on the proxy itself, never delegated, so they pick its OS.
