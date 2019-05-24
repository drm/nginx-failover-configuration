# Simple NginX temporary failover solution

This is a proof of concept for utilizing `proxy_connect_timeout` and a backup
`upstream` server as a temporary failover for NginX.

This is especially useful to spin up a backup instance of your application
while deploying a new version, without losing uptime.

## Principle


## The test

