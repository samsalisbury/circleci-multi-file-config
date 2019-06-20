# Do not copy this Makefile to your project.
# This Makefile is to help with maintenance and testing
# of the stuff in copythis.circleci.

# TD is the test directory. It should be in .gitignore.
TD       := ".tmp/test"
TESTMAKE := make -C $(TD)

# For now, test just invokes ci-config and ci-verify
# and checks they exit successfully.
.PHONY: test
test:
	rm -rf $(TD); mkdir -p $(TD); cp copythis.circleci/Makefile $(TD)/
	$(TESTMAKE) init
	$(TESTMAKE) ci-config
	$(TESTMAKE) ci-verify
