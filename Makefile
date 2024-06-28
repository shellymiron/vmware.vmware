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
	@[ -f /tmp/failed-tests.txt ] && rm /tmp/failed-tests.txt || true; \
	@failed=0; \
	total=0; \
	echo "====================" >> /tmp/failed-tests.txt; \
	echo "  Tests Summary" >> /tmp/failed-tests.txt; \
	echo "====================" >> /tmp/failed-tests.txt; \
	for dir in $(shell ansible-test integration --list-target --no-temp-workdir | grep 'vmware_'); do \
	  echo "Running integration test for $$dir"; \
	  total=$$((total + 1)); \
	  if ansible-test integration --no-temp-workdir $$dir; then \
	    echo "Test: $$dir Passed" | tee -a /tmp/failed-tests.txt; \
	  else \
	    echo "Test: $$dir Failed" | tee -a /tmp/failed-tests.txt; \
	    failed=$$((failed + 1)); \
	  fi; \
	done; \
	  echo "------" >> /tmp/failed-tests.txt; \
	  echo "$$failed test(s) failed out of $$total." >> tee -a /tmp/failed-tests.txt; \
	if [ $$failed -gt 0 ]; then \
	  cat /tmp/failed-tests.txt; \
	  exit 1; \
	fi

