# Common Go code quality tasks (vet test etc.).
#
# Embed into project Makefile like this:
#
#   .common.makefile:
#     curl -fsSL -o $@ https://gitlab.com/bsm/misc/raw/master/make/go/common.makefile
#
#   include .common.makefile
#
# And then .gitignore it: .*.makefile
#

GO_MOD_FILES=$(shell find . -name 'go.mod')

vet:
test: $(patsubst %/go.mod,test/%,$(GO_MOD_FILES))
bench: $(patsubst %/go.mod,bench/%,$(GO_MOD_FILES))
staticcheck: $(patsubst %/go.mod,staticcheck/%,$(GO_MOD_FILES))
tidy: $(patsubst %/go.mod,tidy/%,$(GO_MOD_FILES))

.PHONY: vet test bench staticcheck tidy

test/%: %
	cd $< && go test ./...

bench/%: %
	cd $< && go test ./... -run=NONE -bench=. -benchmem

staticcheck/%: %
	cd $< && staticcheck ./...

tidy/%: %
	cd $< && go mod tidy
