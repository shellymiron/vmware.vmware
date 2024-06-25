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
eco-vcenter-ci: install-python-packages install-ansible-collections prepare_symlinks
	@for dir in $(shell ansible-test integration --list-target --no-temp-workdir | grep 'vmware_ops_'); do \
	  ansible-test integration --no-temp-workdir $$dir; \
	done

