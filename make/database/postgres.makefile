ifndef DATABASE_MIGRATIONS
  DATABASE_MIGRATIONS=db/migrations
endif
ifndef DATABASE_SCHEMA
  DATABASE_SCHEMA=db/schema.sql
endif
ifndef DATABASE_MIGRATE
  DATABASE_MIGRATE=migrate
endif

DATABASE_NAME=$(firstword $(subst ?, ,$(notdir $(DATABASE_URL))))
DATABASE_MAINTENANCE_URL=$(subst $(DATABASE_NAME),postgres,$(DATABASE_URL))

db.create:
	echo "CREATE DATABASE $(DATABASE_NAME) WITH TEMPLATE = template0 ENCODING = 'UTF8'"  | psql -q $(DATABASE_MAINTENANCE_URL)
db.drop:
	echo "DROP DATABASE $(DATABASE_NAME)" | psql -q $(DATABASE_MAINTENANCE_URL)
db.dump:
	pg_dump --no-owner --schema-only --no-privileges --no-acl --no-tablespaces $(DATABASE_URL) > $(DATABASE_SCHEMA)
db.setup: db.create db.migrate
db.recreate: db.drop db.setup

.PHONY: db.create db.drop db.dump db.setup db.recreate

db.migrate: db.migrate.up db.dump
db.migrate.up:
	$(DATABASE_MIGRATE) -database $(DATABASE_URL) -path $(DATABASE_MIGRATIONS) up
db.migrate.down:
	$(DATABASE_MIGRATE) -database $(DATABASE_URL) -path $(DATABASE_MIGRATIONS) down
db.migration:
	@mkdir -p $(DATABASE_MIGRATIONS)
	@if [ -z "$(NAME)" ]; then \
		echo "You must provide a NAME"; \
		exit 1; \
	else \
		timestamp=$$(date +%s); \
		touch $(DATABASE_MIGRATIONS)/$(timestamp)_$(NAME).up.sql $(DATABASE_MIGRATIONS)/$(timestamp)_$(NAME).down.sql; \
	fi

.PHONY: db.migrate db.migrate.up db.migrate.down db.migration