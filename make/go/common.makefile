# Common Go code quality tasks (vet test etc.).
#
# Embed into project Makefile like this:
#
#   .common.makefile:
#     curl -sSL https://gitlab.com/bsm/misc/raw/master/make/go/common.makefile > $@
#
#   include .common.makefile
#

GO_MODULE_DIRS=$(dir $(shell find . -name 'go.mod'))

vet: $(patsubst %/go.mod,vet/%,$(GO_MODULE_DIRS))
test: $(patsubst %/go.mod,test/%,$(GO_MODULE_DIRS))
bench: $(patsubst %/go.mod,bench/%,$(GO_MODULE_DIRS))
staticcheck: $(patsubst %/go.mod,staticcheck/%,$(GO_MODULE_DIRS))
update-deps: $(patsubst %/go.mod,update-deps/%,$(GO_MODULE_DIRS))
tidy: $(patsubst %/go.mod,tidy/%,$(GO_MODULE_DIRS))

.PHONY: vet test bench staticcheck update-deps

vet/%: %
	@cd $< && go vet ./...

test/%: %
	@cd $< && go test ./...

bench/%: %
	@cd $< && go test ./... -run=NONE -bench=. -benchmem

staticcheck/%: %
	@cd $< && staticcheck ./...

update-deps/%: %
	@cd $< && go get -u ./... && go mod tidy

tidy/%: %
	@cd $< && go mod tidy
