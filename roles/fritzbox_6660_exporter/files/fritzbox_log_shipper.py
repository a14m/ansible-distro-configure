#!/usr/bin/env python3
import argparse
import os
import urllib.request
import xml.etree.ElementTree as ET

SOAP_BODY = b"""<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:GetDeviceLog xmlns:u="urn:dslforum-org:service:DeviceInfo:1"/>
  </s:Body>
</s:Envelope>
"""

# How many recently-shipped lines to remember, so a line Fritz!Box happens to
# return again in a later call doesn't get shipped twice. Comfortably bigger
# than the number of lines Fritz!Box returns in a single call.
HISTORY_SIZE = 200


def fetch_log(gateway_url, username, password):
    url = gateway_url.rstrip("/") + "/upnp/control/deviceinfo"
    password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
    password_mgr.add_password(None, url, username, password)
    opener = urllib.request.build_opener(urllib.request.HTTPDigestAuthHandler(password_mgr))
    request = urllib.request.Request(
        url,
        data=SOAP_BODY,
        headers={
            "Content-Type": 'text/xml; charset="utf-8"',
            "SOAPAction": '"urn:dslforum-org:service:DeviceInfo:1#GetDeviceLog"',
        },
    )
    with opener.open(request, timeout=15) as response:
        body = response.read()
    root = ET.fromstring(body)
    log_element = root.find(".//NewDeviceLog")
    if log_element is None or log_element.text is None:
        return []
    # Fritz!Box returns newest-first; reverse for a chronological log file.
    lines = []
    for line in reversed(log_element.text.splitlines()):
        if line.strip():
            lines.append(line)
    return lines


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gateway-url", required=True)
    parser.add_argument("--log-file", required=True)
    parser.add_argument("--state-file", required=True)
    args = parser.parse_args()

    lines = fetch_log(args.gateway_url, os.environ["USERNAME"], os.environ["PASSWORD"])

    try:
        with open(args.state_file) as state_file:
            recent = state_file.read().splitlines()
    except FileNotFoundError:
        recent = []

    new_lines = []
    for line in lines:
        if line not in recent:
            new_lines.append(line)
    if not new_lines:
        return

    with open(args.log_file, "a") as log_file:
        for line in new_lines:
            log_file.write(line + "\n")

    recent = (recent + new_lines)[-HISTORY_SIZE:]
    with open(args.state_file, "w") as state_file:
        state_file.write("\n".join(recent))


if __name__ == "__main__":
    main()
