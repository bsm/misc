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

vet: $(patsubst %/go.mod,vet/%,$(GO_MOD_FILES))
test: $(patsubst %/go.mod,test/%,$(GO_MOD_FILES))
bench: $(patsubst %/go.mod,bench/%,$(GO_MOD_FILES))
staticcheck: $(patsubst %/go.mod,staticcheck/%,$(GO_MOD_FILES))
update-deps: $(patsubst %/go.mod,update-deps/%,$(GO_MOD_FILES))
tidy: $(patsubst %/go.mod,tidy/%,$(GO_MOD_FILES))

.PHONY: vet test bench staticcheck update-deps tidy

vet/%: %
	cd $< && go vet ./...

test/%: %
	cd $< && go test ./...

bench/%: %
	cd $< && go test ./... -run=NONE -bench=. -benchmem

staticcheck/%: %
	cd $< && staticcheck ./...

update-deps/%: %
	cd $< && go get -u ./... && go mod tidy

tidy/%: %
	cd $< && go mod tidy
