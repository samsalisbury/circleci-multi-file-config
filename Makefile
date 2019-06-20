# Do not copy this Makefile to your project.
# This Makefile is to help with maintenance and testing
# of the stuff in copythis.circleci.

SHELL       := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail

# Ensure the .tmp dir always exists.
$(shell [ -d .tmp ] || mkdir -p .tmp)

# TD is the test directory. It should be in .gitignore.
TD       := .tmp/test
TESTMAKE := make -C $(TD)

define TESTSETUP
	[ ! -d $(TD) ] || rm -rf $(TD)
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
