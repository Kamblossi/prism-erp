# PrismERP Dev Port Exposure Runbook

## Desired dev posture

The dev stack should be accessed through SSH tunnel only.

Raw port 8080 should not be reachable from the public internet.

## Current access model

Local laptop:

```bash
ssh -L 8080:localhost:8080 azureuser@4.222.235.17
```

Browser:
```
http://dev-erp.prismtechco.com:8080
http://tenant1-dev-erp.prismtechco.com:8080
```
with local hosts-file entries pointing those domains to `127.0.0.1`.

## Checks

```bash
ss -ltnp | grep -E ':(22|80|443|8080|8000|9000|3306|6379)\b' || true
docker ps --format "table {{.Names}}\t{{.Ports}}"
sudo ufw status verbose
```

## Expected

- MariaDB 3306 not publicly exposed
- Redis 6379 not publicly exposed
- Websocket/internal ports not publicly exposed
- 8080 not allowed from Internet through UFW or Azure NSG

## Azure NSG rule

In Azure Portal, the VM Network Security Group should not allow inbound TCP 8080 from Internet.

Allowed inbound during development:
- 22/tcp from trusted admin IP only

Only later, when production HTTPS is intentionally configured:
- 80/tcp
- 443/tcp

Do not allow:
- 8080
- 8000
- 9000
- 3306
- 6379
