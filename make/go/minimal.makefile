# Common Go code quality tasks (vet test etc.).
#
# Embed into project Makefile like this:
#
#   .minimal.makefile:
#     curl -fsSL -o $@ https://gitlab.com/bsm/misc/raw/master/make/go/minimal.makefile
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

tidy:
	go mod tidy

.PHONY: test bench staticcheck tidy
