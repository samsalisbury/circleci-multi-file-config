# Do not copy this Makefile to your project.
# This Makefile is to help with maintenance and testing
# of the stuff in copythis.circleci.

# Set SHELL to 'strict mode' without using .SHELLFLAGS for max compatibility.
# See https://fieldnotes.tech/how-to-shell-for-compatible-makefiles/
SHELL := /usr/bin/env bash -euo pipefail -c

# CCI_VERSION is the CircleCI CLI Version; this env var can be overridden
# to test this against different versions of the CLI.
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
CCI_PATH := $(CURDIR)/$(CCI_DIR)/$(CCI_NAME)
CCI := $(CCI_DIR)/$(CCI_NAME)/circleci

.PHONY: get-circleci-cli
get-circleci-cli: $(CCI)

$(CCI):
	mkdir -p $(CCI_DIR)
	cd $(CCI_DIR) && wget $(CCI_URL) && tar xfv $(CCI_ARCHIVE)

# TD is the test directory. It should be in .gitignore.
TESTREPO := .tmp/testrepo
TD       := $(TESTREPO)/.circleci

# TESTMAKE invokes make setting its path to use the CircleCI CLI version specified
# by CCI_VERISON, and runs it inside the test directory TD.
TESTMAKE = @export PATH=$(CCI_PATH):$(PATH) && \
	echo "==> make $(1)" && \
	make --no-print-directory -C $(TD) $(1)

# TESTSETUP nukes & re-creates the test dir, and copies in copythis.circleci
# as .circleci, simulating following the installation instructions.
define TESTSETUP
	@[ ! -d $(TD) ] || rm -r $(TD)
	@mkdir -p $(TD)
	@cp copythis.circleci/Makefile $(TD)/
	@echo "==> Begin Tests: CircleCI CLI v$(CCI_VERSION)"
	@# Call make init-simple-source from this file to dump some elementary
	@# config into the test directory ready for the test to operate on.
	@SOURCE_DIR=config $(MAKE) -C $(TD) -f $(CURDIR)/Makefile init
endef

# For now, test just invokes ci-config and ci-verify against the simple config
# defined by make init, and checks they exit successfully.
.PHONY: test
test: $(CCI)
	$(TESTSETUP)
	$(call TESTMAKE,help)
	$(call TESTMAKE,ci-config)
	$(call TESTMAKE,ci-verify)
	@echo "==> Compiled config.yml:"
	@cat $(TD)/config.yml
	@echo OK - all tests passed

CONFIG_ROOT := $(SOURCE_DIR)/@$(SOURCE_DIR).yml

.PHONY: init-simple-source
init: ## init creates just enough to allow make ci-config to run without error.
	@[ ! -d $(SOURCE_DIR) ] || { echo "Source directory $(SOURCE_DIR)/ already exists."; exit 1; }
	@mkdir -p $(SOURCE_DIR) $(SOURCE_DIR)/{jobs,commands,workflows}
	@printf -- "---\nversion: 2.1\njobs:\n" > $(CONFIG_ROOT)
	@echo File $(CONFIG_ROOT) created.

.PHONY: clean
clean:
	rm -r .tmp
