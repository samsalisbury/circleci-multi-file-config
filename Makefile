# Do not copy this Makefile to your project.
# This Makefile is to help with maintenance and testing
# of the stuff in copythis.circleci.

# Set SHELL to 'strict mode' without using .SHELLFLAGS for max compatibility.
# See https://fieldnotes.tech/how-to-shell-for-compatible-makefiles/
SHELL := /usr/bin/env bash -euo pipefail -c

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
	cd $(CCI_DIR) && wget $(CCI_URL) && tar xfv $(CCI_ARCHIVE)

# TD is the test directory. It should be in .gitignore.
TESTREPO := .tmp/testrepo
TD       := $(TESTREPO)/.circleci
TESTMAKE = @export PATH=$(CCI_PATH):$(PATH) && \
	echo "==> make $(1)" && \
	make --no-print-directory -C $(TD) $(1)

define TESTSETUP
	@[ ! -d $(TD) ] || rm -r $(TD)
	@mkdir -p $(TD)
	@cp copythis.circleci/Makefile $(TD)/
	@echo "==> Begin Tests: CircleCI CLI v$(CCI_VERSION)"
endef

# For now, test just invokes ci-config and ci-verify against the simple config
# defined by make init, and checks they exit successfully.
.PHONY: test
test: $(CCI)
	$(TESTSETUP)
	$(call TESTMAKE,help)
	SOURCE_DIR=config $(MAKE) -C $(TD) -f $(PWD)/Makefile init
	$(call TESTMAKE,ci-config)
	$(call TESTMAKE,ci-verify)
	@echo OK - all tests passed

CONFIG_ROOT := $(SOURCE_DIR)/@$(SOURCE_DIR).yml

.PHONY: init
init: ## init creates just enough to allow make ci-config to run without error.
	@[ ! -d $(SOURCE_DIR) ] || { echo "Source directory $(SOURCE_DIR)/ already exists."; exit 1; }
	@mkdir -p $(SOURCE_DIR) $(SOURCE_DIR)/{jobs,commands,workflows}
	@printf -- "---\nversion: 2.1\njobs:\n" > $(CONFIG_ROOT)
	@echo File $(CONFIG_ROOT) created.

.PHONY: clean
clean:
	rm -r .tmp
