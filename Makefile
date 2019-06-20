# Do not copy this Makefile to your project.
# This Makefile is to help with maintenance and testing
# of the stuff in copythis.circleci.

SHELL       := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

CCI_VERSION ?= 0.1.5652

ifeq ($(shell uname),Darwin)
CCI_OS_ARCH := darwin_amd64
else
CCI_OS_ARCH := linux_amd64
endif

CCI_NAME := circleci-cli_$(CCI_VERSION)_$(CCI_OS_ARCH)
CCI_ARCHIVE := $(CCI_NAME).tar.gz
CCI_URL := https://github.com/CircleCI-Public/circleci-cli/releases/download/v$(CCI_VERSION)/$(CCI_ARCHIVE)
CCI_DIR := .tmp/clients/$(CCI_VERSION)
CCI_PATH := $(PWD)/$(CCI_DIR)/$(CCI_NAME)
CCI := $(CCI_DIR)/$(CCI_NAME)/circleci

.PHONY: get-circleci-cli
get-circleci-cli: $(CCI)

$(CCI):
	mkdir -p $(CCI_DIR)
	cd $(CCI_DIR) && wget $(CCI_URL) && tar xfv $(CCI_ARCHIVE) && chmod +x $@

# TD is the test directory. It should be in .gitignore.
TD       := .tmp/test
TESTMAKE = @export PATH=$(CCI_PATH):$(PATH) && \
	echo "==> make $(1)" && \
	make -C $(TD) $(1)

define TESTSETUP
	@[ ! -d $(TD) ] || rm -r $(TD)
	@mkdir -p $(TD)
	@cp copythis.circleci/Makefile $(TD)/
	@echo "===== Begin Tests: CircleCI CLI v$(CCI_VERSION)"
endef

# For now, test just invokes ci-config and ci-verify
# and checks they exit successfully.
.PHONY: test
test: $(CCI)
	$(TESTSETUP)
	$(call TESTMAKE,help)
	$(call TESTMAKE,init)
	$(call TESTMAKE,ci-config)
	$(call TESTMAKE,ci-verify)
	@echo OK - all tests passed

.PHONY: clean
clean:
	rm -r .tmp
