# Ansible Role: servarr

No tasks: ships the `servarr_resources` module for roles that depend on it (`sonarr`, `radarr`, `prowlarr`).

`servarr_resources` makes an API collection (root folders, download clients, applications, ...) match a list: it adds
missing resources, updates changed ones and deletes unlisted ones, matched by `key` (default `name`). `fields` can be a
mapping, `defaults` is merged into every resource, and `configContract` defaults to `<implementation>Settings`.

```yaml
- servarr_resources:
    url: "http://192.168.0.122:8989/api/v3/downloadclient"
    api_key: "{{ sonarr_api_key }}"
    resources:
      - name: "qBittorrent"
        implementation: "QBittorrent"
        fields: { host: "192.168.0.121", port: 8080 }
```

The API masks secrets (`********`), so they aren't compared; they're re-sent with every update of a resource that has
them, without reporting a change.
