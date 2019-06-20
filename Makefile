# Do not copy this Makefile to your project.
# This Makefile is to help with maintenance and testing
# of the stuff in copythis.circleci.

SHELL       := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail

# Ensure the .tmp dir always exists.
$(shell if [ ! -d ./.tmp ]; then mkdir -p ./.tmp; fi)

# TD is the test directory. It should be in .gitignore.
TD       := .tmp/test
TESTMAKE := make -C $(TD)

define TESTSETUP
	set -x
	whoami
	ls -lah .
	if [ -d $(TD) ]; then rm -rf $(TD); fi
	mkdir -p $(TD)
	cp copythis.circleci/Makefile $(TD)/
endef

# For now, test just invokes ci-config and ci-verify
# and checks they exit successfully.
.PHONY: test
test:
	$(TESTSETUP)
	$(TESTMAKE) init
	$(TESTMAKE) ci-config
	$(TESTMAKE) ci-verify
