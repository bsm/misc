# Go (and Ruby) protobuf tasks on top of github.com/gogo/protobuf.
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
# If you want to redirect your ruby output to a different path:
#
#   include .protogo.makefile
#
#   proto.rb: lib/my_module/klass_pb.rb
#
#   lib/my_module/klass_pb.rb: klasspb/klass_pb.rb
#     @mkdir -p $(dir $@)
#     cp -f $< $@
#

PROTOGO_FLAG += paths=source_relative
PROTOGO_PATH ?= .:internal/protobuf:internal/protobuf/github.com/gogo/protobuf/protobuf

PROTOGO_DEPS =
PROTOGO_DEPS += internal/protobuf/github.com/gogo/protobuf/gogoproto/gogo.proto
PROTOGO_DEPS += internal/protobuf/github.com/gogo/protobuf/protobuf/google/protobuf/descriptor.proto

PROTOGO_REPO = $(shell go list -m -f '{{.Dir}}' github.com/gogo/protobuf)
PROTOGO_SRCS = $(wildcard *.proto **/*.proto)

protogo_comma = ,

proto.go: $(patsubst %.proto,%.pb.go,$(PROTOGO_SRCS))
proto.rb: $(patsubst %.proto,%_pb.rb,$(PROTOGO_SRCS))

.PHONY: proto.go proto.rb

%.pb.go: %.proto $(PROTOGO_DEPS)
	protoc --gogo_out=$(subst $(eval) ,$(protogo_comma),$(PROTOGO_FLAG)):. --proto_path=$(PROTOGO_PATH) $<

%_pb.rb: %.proto $(PROTOGO_DEPS)
	protoc --ruby_out=. --proto_path=$(PROTOGO_PATH) $<

# ---------------------------------------------------------------------

internal/protobuf/github.com/gogo/%:
	go mod download

internal/protobuf/github.com/gogo/protobuf/gogoproto/gogo.proto: $(PROTOGO_REPO)/gogoproto/gogo.proto go.sum
	@mkdir -p $(dir $@)
	cp -f $< $@

internal/protobuf/github.com/gogo/protobuf/protobuf/google/protobuf/descriptor.proto: $(PROTOGO_REPO)/protobuf/google/protobuf/descriptor.proto go.sum
	@mkdir -p $(dir $@)
	cp -f $< $@
