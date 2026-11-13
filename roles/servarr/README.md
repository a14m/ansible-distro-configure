# Ansible Role: servarr

Shared pieces for the Servarr apps (`sonarr`, `radarr`, `prowlarr`); no main tasks.

## tasks/app.yml

Installs one app as its own user and systemd service (`/opt/<App>`, data in `/var/lib/<app>`), used through
`include_role: {name: servarr, tasks_from: app}` with `servarr_*` vars (see `meta/argument_specs.yml`):

- installs the latest release once; the app updates itself afterwards
- sets `config.xml` keys: LAN bind, port, API key, login required, allowed hosts, analytics off
- the login user is created on the first visit; files are group-writable (`UMask=0002`)
- adds the proxy vhost when `servarr_hostname` is set

## servarr_resources module

Makes an API collection (root folders, download clients, applications, ...) match a list: adds missing resources and
updates changed ones, matched by `key` (default `name`). `prune` (required) says whether unlisted ones are deleted:
`true` when the list is the whole collection, `false` when sharing it (e.g. an app registering itself in Prowlarr).
`fields` can be a mapping, `defaults` is merged into every resource, and `configContract` defaults to
`<implementation>Settings`.

```yaml
- servarr_resources:
    url: "http://192.168.0.122:8989/api/v3/downloadclient"
    api_key: "{{ sonarr_api_key }}"
    resources:
      - name: "qBittorrent"
        implementation: "QBittorrent"
        fields: { host: "192.168.0.121", port: 8080 }
    prune: true
```

Secrets come back masked (`********`), so they aren't compared, but are re-sent with every update.
