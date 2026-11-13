#!/usr/bin/python
"""Make a list of Sonarr/Radarr/Prowlarr API resources match the desired list."""

import json

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.urls import fetch_url

DOCUMENTATION = r"""
module: servarr_resources
short_description: Make a Servarr API collection (root folders, download clients, applications, ...) match a list
description:
  - Reads the collection at O(url), adds missing resources, updates changed ones and, with O(prune), deletes unlisted
    ones.
  - Resources are matched by O(key). O(fields) may be given as a mapping; it is sent as the API's name/value list.
  - Secrets come back from the API masked (C(********)), so they are not compared, but they are re-sent with every
    update of a resource that has them.
options:
  url:
    description: Collection endpoint, e.g. C(http://host:8989/api/v3/downloadclient).
    type: str
    required: true
  api_key:
    description: The app's API key.
    type: str
    required: true
    no_log: true
  resources:
    description: Desired resources.
    type: list
    elements: dict
    required: true
  key:
    description: Attribute identifying a resource.
    type: str
    default: name
  defaults:
    description: Merged into every resource (O(fields) merged too).
    type: dict
    default: {}
  prune:
    description: Delete resources not in O(resources). False manages only the listed ones (e.g. an app registering
      itself in a shared collection).
    type: bool
    required: true
"""

MASKED = "********"


def request(module, method, url, body=None):
    data = json.dumps(body) if body is not None else None
    resp, info = fetch_url(
        module, url, data=data, method=method,
        headers={"X-Api-Key": module.params["api_key"], "Content-Type": "application/json"},
    )
    if info["status"] >= 400 or info["status"] < 0:
        module.fail_json(msg=f"{method} {url} failed: {info.get('status')} {info.get('body', info.get('msg'))}")
    content = resp.read() if resp else b""
    return json.loads(content) if content else None


def desired_resource(resource, defaults):
    merged = {**defaults, **resource}
    fields = {**defaults.get("fields", {}), **resource.get("fields", {})}
    if "implementation" in merged and "configContract" not in merged:
        merged["configContract"] = merged["implementation"] + "Settings"
    if fields:
        merged["fields"] = [{"name": name, "value": value} for name, value in fields.items()]
    return merged


def differs(desired, existing):
    """True if a visible (non-masked) setting differs; second value: whether masked secrets exist."""
    has_secret = False
    for name, value in desired.items():
        if name == "fields":
            current = {f["name"]: f.get("value") for f in existing.get("fields", [])}
            for field in value:
                if current.get(field["name"]) == MASKED:
                    has_secret = True
                elif current.get(field["name"]) != field["value"]:
                    return True, has_secret
        elif existing.get(name) != value:
            return True, has_secret
    return False, has_secret


def main():
    module = AnsibleModule(
        argument_spec={
            "url": {"type": "str", "required": True},
            "api_key": {"type": "str", "required": True, "no_log": True},
            "resources": {"type": "list", "elements": "dict", "required": True},
            "key": {"type": "str", "default": "name"},
            "defaults": {"type": "dict", "default": {}},
            "prune": {"type": "bool", "required": True},
        },
        supports_check_mode=True,
    )
    url, key = module.params["url"].rstrip("/"), module.params["key"]
    desired = [desired_resource(r, module.params["defaults"]) for r in module.params["resources"]]
    existing = {r[key]: r for r in request(module, "GET", url)}
    result = {"changed": False, "added": [], "updated": [], "removed": []}

    for resource in desired:
        current = existing.pop(resource[key], None)
        if current is None:
            result["added"].append(resource[key])
            if not module.check_mode:
                request(module, "POST", f"{url}?forceSave=true", resource)
            continue
        changed, has_secret = differs(resource, current)
        if changed:
            result["updated"].append(resource[key])
        # Secrets can't be compared, so they are re-sent; that alone is not reported as a change
        if (changed or has_secret) and not module.check_mode:
            request(module, "PUT", f"{url}/{current['id']}?forceSave=true", {**resource, "id": current["id"]})

    for name, current in existing.items() if module.params["prune"] else []:
        result["removed"].append(name)
        if not module.check_mode:
            request(module, "DELETE", f"{url}/{current['id']}")

    result["changed"] = bool(result["added"] or result["updated"] or result["removed"])
    module.exit_json(**result)


if __name__ == "__main__":
    main()
