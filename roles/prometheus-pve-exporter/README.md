# prometheus-pve-exporter Role

Installs [`prometheus-pve-exporter`](https://github.com/prometheus-pve/prometheus-pve-exporter) in a virtualenv on
the PVE host and creates a read-only (`PVEAuditor`) PVE user for it.

## Scraping

Serves `/pve` (not `/metrics`) on `prometheus_pve_exporter_port`; `target` defaults to `localhost`. See
`host_vars/metrics.home.arpa.yml.example`.

## Dashboard

grafana.com [24070](https://grafana.com/grafana/dashboards/24070) - 10347 with guest/node CPU no longer divided by
core count twice.
