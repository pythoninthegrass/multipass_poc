# https://just.systems/man/en

# load .env
set dotenv-load

# # set env var
export APP		:= "cloud-conf"
export CONF		:= "cloud-init.yml"
export CPU		:= "4"
export DISK		:= "5G"
export DRIVER   := "qemu"
export ENTRY	:= "cloud-init.yml"
export MEM		:= "4G"
export PLAY     := "hardening.yml"
export VM		:= "testvm"

# x86_64/arm64
arch := `uname -m`

# # hostname
# host := `uname -n`

# # operating system
# os := `uname -s`

# # home directory
# home_dir := env_var('HOME')

# docker-compose / docker compose
# * https://docs.docker.com/compose/install/linux/#install-using-the-repository
docker-compose := if `command -v docker-compose; echo $?` == "0" {
	"docker-compose"
} else {
	"docker compose"
}

# [halp]     list available commands
default:
	just --list

# [deps]     update dependencies
update-deps:
	#!/usr/bin/env bash
	# set -euxo pipefail
	find . -maxdepth 3 -name "pyproject.toml" -exec \
		echo "[{}]" \; -exec \
		echo "Clearring pypi cache..." \; -exec \
		poetry cache clear --all pypi --no-ansi \; -exec \
		poetry update --lock --no-ansi \;

# [deps]     export requirements.txt
export-reqs: update-deps
	#!/usr/bin/env bash
	# set -euxo pipefail
	find . -maxdepth 3 -name "pyproject.toml" -exec \
		echo "[{}]" \; -exec \
		echo "Exporting requirements.txt..." \; -exec \
		poetry export --no-ansi --without-hashes --output requirements.txt \;

# [multi]    list multipass instances
list:
	multipass list

# [multi]    multipass instance info
info:
    multipass info --format yaml {{VM}}

# TODO: QA
# [multi]    multipass vm driver
driver:
    # multipass set local.passphrase
    # multipass authenticate
    multipass set local.driver={{DRIVER}}
    multipass get local.driver

# [multi]    launch multipass instance
launch:
	multipass launch -n {{VM}} \
	--cpus {{CPU}} \
	--memory {{MEM}} \
	--disk {{DISK}} \
	--cloud-init {{CONF}} \
	-v

# [multi]    start multipass instance
start:
	multipass start {{VM}}

# [multi]    shell into multipass instance
shell: start
	multipass shell {{VM}}

# [multi]    stop multipass instance
stop:
	multipass stop {{VM}}

# [multi]    delete multipass instance
delete: stop
	multipass delete {{VM}}

# [multi]    purge multipass instance
purge: delete
	multipass purge

# [docker]   build locally
build:
	#!/usr/bin/env bash
	set -euxo pipefail
	if [[ {{arch}} == "arm64" ]]; then
		docker build -f Dockerfile -t {{APP}} --build-arg CHIPSET_ARCH=aarch64-linux-gnu .
	else
		docker build -f Dockerfile --progress=plain -t {{APP}} .
	fi

# [check]    validate cloud-init.yaml
check-ci:
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
	--name {{APP}} \
	-h ${HOST:-localhost} \
	-v $(pwd):/app \
	{{APP}} \
	{{ENTRY}}

# [ansible]  run ansible playbook
ansible: start
	#!/usr/bin/env bash
	# set -euxo pipefail
	multipass exec {{VM}} -- \
	cd /home/ubuntu/git/ansible-role-hardening/tasks \
	&& ansible-playbook hardening.yml -i /etc/ansible/hosts
