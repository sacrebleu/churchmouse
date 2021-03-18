# grafana-migrator

#### Overview

grafana-migrator is a tool to migrate dashboards from a souce to target grafana

#### Methodology

#### Usage: 

Configure the application with a config.yaml under /config:

    ---
    source:
    url: <source url> # eg. https://metrics.nexmo.io:8443/grafana
    key: <source key> # api key
    org_id: <source org> # e.g 13
    target:
    url: <target url> # e.g https://grafana01.nexmo.vip
    key: <terget key> # requires admin access
    org_id: <target org> # eg 42

Then run with --export to export and save the source dashboards to file.

Run with --import to push these dashboards to the target grafana