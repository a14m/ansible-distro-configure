# fritzbox_6660_exporter Role

Installs [`sberk42/fritzbox_exporter`](https://github.com/sberk42/fritzbox_exporter) as a systemd service against an
AVM Fritz!Box over TR-064 and lua. On cable models (e.g. FRITZ!Box 6660 Cable) it exports per-channel DOCSIS
diagnostics - enough to tell a local network problem from an ISP line fault.

## Variables

```yaml
fritzbox_6660_exporter_gateway_url: "http://<router_ip>:49000"  # required, TR-064 endpoint
fritzbox_6660_exporter_username: "monitoring"                   # required
fritzbox_6660_exporter_password: "..."                          # required
fritzbox_6660_exporter_gateway_luaurl: "http://<router_ip>"     # derived from gateway_url
fritzbox_6660_exporter_port: 9042
fritzbox_6660_exporter_listen_address: "0.0.0.0:9042"
```

## Fritz!Box setup (manual, one-time)

1. **System → FRITZ!Box Users**: add a user (e.g. `monitoring`) with **"FRITZ!Box Settings"** permission.
2. **Home Network → Network → Network Settings**: enable **"Transmit status information over UPnP"** (needed for
   TR-064 metrics).

## Key cable/DOCSIS metrics

| Metric | Meaning |
|---|---|
| `gateway_cable_power_downstream{,31}` / `gateway_cable_power_upstream{,31}` | per-channel RX/TX level (dBmV) |
| `gateway_cable_mse_downstream` | downstream MER/SNR (dB) |
| `gateway_cable_correctables_downstream` / `gateway_cable_uncorrectables_downstream` | FEC error counters - rising uncorrectables = line fault |

Plus TR-064 WAN status, uptime, negotiated bitrate, and byte/packet counters from `metrics.json`.

## Scraping

Serves `/metrics` on `fritzbox_6660_exporter_port`. Add a Prometheus job (see
`host_vars/metrics.home.arpa.yml.example`); 60s interval is enough - the lua `docInfo` call is slow.

## Dashboard

`files/grafana-dashboard.json` - cable link, provisioned rate, throughput vs capacity, per-channel DOCSIS power,
MSE, and codeword-error rates. Provision via the `grafana` role:

```yaml
- name: "fritzbox"
  source: "roles/fritzbox_6660_exporter/files/grafana-dashboard.json"
```

## Notes

- Upstream only publishes a rolling `latest` asset, so the binary is downloaded once (stat-guarded) and not
  re-fetched on later runs.
- grafana.com dashboard 12579 is DSL-oriented - its WAN-status and sync-rate panels query PPPoE metrics
  (`gateway_connection_*`) a cable box doesn't expose, so it's not used here.
