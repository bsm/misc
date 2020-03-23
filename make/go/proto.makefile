# Go protobuf tasks.
#
# Embed into project Makefile like this:
#
#   .protogo.makefile:
#     curl -fsSL -o $@ https://gitlab.com/bsm/misc/raw/master/make/go/proto.makefile
#
#   include .protogo.makefile
#
# Ensure your .gitignore contains the following lines:
#
#   .*.makefile
#   internal/protobuf/
#
# For grpc support, include the following line:
#
#   PROTOGO_FLAG=plugins=grpc
#

PROTOGO_DEPS =
PROTOGO_DEPS += internal/protobuf/github.com/gogo/protobuf/gogoproto/gogo.proto
PROTOGO_DEPS += internal/protobuf/github.com/gogo/protobuf/protobuf/google/protobuf/descriptor.proto

PROTOGO_PATH ?= .
PROTOGO_PATH += internal/protobuf:internal/protobuf/github.com/gogo/protobuf/protobuf

PROTOGO_FLAG += paths=source_relative

PROTOGO_REPO = $(shell go list -m -f '{{.Dir}}' github.com/gogo/protobuf)
PROTOGO_SRCS = $(wildcard *.proto **/*.proto)

protogo_comma = ,

proto.go: $(patsubst %.proto,%.pb.go,$(PROTOGO_SRCS))

.PHONY: proto.go proto.go.deps

%.pb.go: %.proto $(PROTOGO_DEPS)
	protoc --gogo_out=$(subst $(eval) ,$(protogo_comma),$(PROTOGO_FLAG)):. --proto_path=$(subst $(eval) ,:,$(PROTOGO_PATH)) $<

internal/protobuf/github.com/gogo/%:
	go mod download

internal/protobuf/github.com/gogo/protobuf/gogoproto/gogo.proto: $(PROTOGO_REPO)/gogoproto/gogo.proto go.sum
	@mkdir -p $(dir $@)
	cp -f $< $@

internal/protobuf/github.com/gogo/protobuf/protobuf/google/protobuf/descriptor.proto: $(PROTOGO_REPO)/protobuf/google/protobuf/descriptor.proto go.sum
	@mkdir -p $(dir $@)
	cp -f $< $@
