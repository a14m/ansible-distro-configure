# fritzbox_6660_exporter Role

Installs [`sberk42/fritzbox_exporter`](https://github.com/sberk42/fritzbox_exporter)
as a systemd service and points it at an AVM Fritz!Box over the TR-064 and lua
APIs. On cable models (e.g. FRITZ!Box 6660 Cable) it exports per-channel DOCSIS
diagnostics — the data needed to tell a local network problem apart from an ISP
line fault.

## Variables

```yaml
fritzbox_6660_exporter_gateway_url: "http://<router_ip>:49000"  # required, TR-064 endpoint
fritzbox_6660_exporter_username: "monitoring"                   # required
fritzbox_6660_exporter_password: "..."                          # required
fritzbox_6660_exporter_gateway_luaurl: "http://<router_ip>"     # derived from gateway_url
fritzbox_6660_exporter_port: 9042
fritzbox_6660_exporter_listen_address: "0.0.0.0:9042"
```

Upstream only publishes a rolling `latest` release asset, so the binary is
downloaded once (guarded by a stat check) and not re-fetched on later runs.

## Fritz!Box setup (manual, one-time)

1. **System → FRITZ!Box Users**: add a user (e.g. `monitoring`) with the
   **"FRITZ!Box Settings"** permission.
2. **Home Network → Network → Network Settings**: enable
   **"Transmit status information over UPnP"** (needed for the TR-064 metrics).

## Key cable/DOCSIS metrics

| Metric | Meaning |
|---|---|
| `gateway_cable_power_downstream{,31}` / `gateway_cable_power_upstream{,31}` | per-channel RX/TX level (dBmV) |
| `gateway_cable_mse_downstream` | downstream MER/SNR (dB) |
| `gateway_cable_correctables_downstream` / `gateway_cable_uncorrectables_downstream` | FEC error counters — rising uncorrectables = line fault |

Plus TR-064 WAN status, uptime, negotiated bitrate, and byte/packet counters
from `metrics.json`.

## Scraping

The exporter serves `/metrics` on `fritzbox_6660_exporter_port`. Add a Prometheus job
(see `host_vars/metrics.home.arpa.yml.example`); a 60s interval is enough, the
lua `docInfo` call is slow.

## Dashboard

`files/grafana-dashboard.json` — cable link, provisioned rate, throughput vs
capacity, and per-channel DOCSIS downstream/upstream power, MSE and codeword-error
rates. Provision via the `grafana` role's `grafana_dashboards`:

```yaml
- name: "fritzbox"
  source: "roles/fritzbox_6660_exporter/files/grafana-dashboard.json"
```

The published grafana.com dashboard 12579 is DSL-oriented — its WAN-status and
sync-rate panels query PPPoE metrics (`gateway_connection_*`) that a cable box
does not expose, so it is not used here.
