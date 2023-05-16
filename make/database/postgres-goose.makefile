# Common PostgreSQL database tasks.
#
# Embed into project Makefile like this:
#
#   DATABASE_URL ?= postgres://127.0.0.1/DBNAME?sslmode=disable
#
#   .database.makefile:
#     curl -fsSL -o $@ https://gitlab.com/bsm/misc/raw/master/make/database/postgres-goose.makefile
#
#   include .database.makefile
#
# And then .gitignore it: .*.makefile
#

# go install github.com/pressly/goose/v3/cmd/goose@latest
GOOSE_MIGRATION_DIR ?= db/migrations
GOOSE_DRIVER ?= postgres
GOOSE_DBSTRING ?= $(DATABASE_URL)
GOOSE_CMD ?= GOOSE_MIGRATION_DIR=$(GOOSE_MIGRATION_DIR) GOOSE_DRIVER=$(GOOSE_DRIVER) GOOSE_DBSTRING=$(GOOSE_DBSTRING) goose

DATABASE_SCHEMA ?= db/schema.sql

DATABASE_NAME=$(firstword $(subst ?, ,$(notdir $(DATABASE_URL))))
DATABASE_MAINTENANCE_URL=$(subst $(DATABASE_NAME),postgres,$(DATABASE_URL))

.PHONY: db.create db.drop db.dump db.psql

db.create:
	echo "CREATE DATABASE $(DATABASE_NAME) WITH TEMPLATE = template0 ENCODING = 'UTF8'"  | psql -q $(DATABASE_MAINTENANCE_URL)
db.drop:
	echo "DROP DATABASE $(DATABASE_NAME)" | psql -q $(DATABASE_MAINTENANCE_URL)
db.dump:
	pg_dump --no-owner --schema-only --no-privileges --no-acl --no-tablespaces $(DATABASE_URL) -f $(DATABASE_SCHEMA)
db.psql:
	psql $(DATABASE_URL)

.PHONY: db.setup db.recreate

db.setup: db.create db.migrate
db.recreate: db.drop db.setup

.PHONY: db.migrate db.migrate.up db.migrate.down db.migrate.status db.migrate.new

db.migrate:
	$(GOOSE_CMD) up # migrate all
db.migrate.up:
	$(GOOSE_CMD) up-by-one
db.migrate.down:
	$(GOOSE_CMD) down
db.migrate.status:
	$(GOOSE_CMD) status
db.migrate.new:
	@if [ -z "$(NAME)" ]; then \
		echo "You must provide a NAME"; \
		exit 1; \
	else \
		mkdir -p $(GOOSE_MIGRATION_DIR); \
		$(GOOSE_CMD) create $(NAME) sql; \
	fi
