units:
	ansible-test units --docker --python 3.12

# this playbook aims to create a symlink for the runme.sh script
# for each integration target so that ansible-test will recognize it for the target
# and the script will run the test
.PHONY: prepare_symlinks
prepare_symlinks:
	ansible-playbook tools/prepare_symlinks.yml

integration: prepare_symlinks
	ansible-test integration --no-temp-workdir

.PHONY: eco-vcenter-ci
eco-vcenter-ci: prepare_symlinks
	@mkdir -p test-results
	@failed=0; \
	for dir in $(shell ansible-test integration --list-target --no-temp-workdir | grep 'vmware_'); do \
	  echo "Running integration test for $$dir"; \
	  if ! output=$$(ansible-test integration --no-temp-workdir $$dir 2>&1); then \
	    echo "target name: $$dir" >> /tmp/failed-tests.txt; \
	    echo "failed on: $$(date)" >> /tmp/failed-tests.txt; \
	    echo "error message: $$output" >> /tmp/failed-tests.txt; \
	    echo "-----------------------------" >> /tmp/failed-tests.txt; \
	    failed=$$((failed + 1)); \
	    echo "$$failed tests failed in total" >> /tmp/failed-tests.txt; \
	  fi; \
	done; \
	if [ $$failed -gt 0 ]; then \
	  echo "$$failed tests failed"; \
	  echo "Summary of failed tests:"; \
	  echo "========================"; \
	  cat test-results/failed-tests.txt; \
	  exit 1; \
	fi
