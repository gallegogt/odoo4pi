

```
docker-compose exec odoo_web bash
odoo -i base -d odoo --stop-after-init --db_host=odoo_db -r odoo -w odoo
docker-compose down
docker-compose up -d
```