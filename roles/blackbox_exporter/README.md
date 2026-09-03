# blackbox_exporter Role

Installs [`prometheus/blackbox_exporter`](https://github.com/prometheus/blackbox_exporter)
as a systemd service for active reachability probing (ICMP / DNS / HTTP). It
answers the question the `fritzbox_6660_exporter` cannot: is loss/latency to a
given destination the cable line, the LAN, or ISP-side routing?

## Variables

```yaml
blackbox_exporter_version: "0.28.0"
blackbox_exporter_port: 9115
blackbox_exporter_modules: { ... }   # icmp / http_2xx / dns_a by default
```

Probe **targets** are not set here — they live in the Prometheus scrape config
(`prometheus_extra_scrape_configs`), using the multi-target `/probe` pattern with
`params` + `relabel_configs`. See `host_vars/metrics.home.arpa.yml.example`.

## Dashboard

Grafana.com [7587](https://grafana.com/grafana/dashboards/7587) ("Prometheus
Blackbox Exporter") via the `grafana` role's `grafana_dashboards`:

```yaml
- name: "blackbox"
  source: "https://grafana.com/api/dashboards/7587/revisions/3/download"
  datasource_mappings:
    - key: "${DS_SIGNCL-PROMETHEUS}"
      value: "prometheus"
```

## Reading it

- `probe_success` — 1/0 per target. Gateway up + `1.1.1.1` down = ISP routing.
- `probe_icmp_duration_seconds{phase="rtt"}` — round-trip latency per target.
- `probe_duration_seconds` for HTTP/DNS — full-path timing.
- Run it from rpi5 (the gateway) so probes take the real egress path.
