# Common Go code quality tasks (vet test etc.).
#
# Embed into project Makefile like this:
#
#   .minimal.makefile:
#     curl -fsSL -o $@ https://raw.githubusercontent.com/bsm/misc/main/make/go/minimal.makefile
#
#   include .minimal.makefile
#
# And then .gitignore it: .*.makefile
#

test:
	go test ./...

bench:
	go test ./... -run=NONE -bench=. -benchmem

staticcheck:
	staticcheck ./...

lint:
	golangci-lint run

tidy:
	go mod tidy

.PHONY: test bench staticcheck tidy
