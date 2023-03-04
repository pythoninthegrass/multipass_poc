# https://just.systems/man/en

# load .env
set dotenv-load

# positional params
set positional-arguments

# # set env var
export APP		:= `echo ${APP_NAME:-"cloud-conf"}`
export CONF		:= `echo ${CONF:-"cloud-init.yml"}`
export CWD      := `echo ${CWD:-"$(pwd)"}`
export CPU		:= `echo ${CPU:-"4"}`
export DISK		:= `echo ${DISK:-"5G"}`
export DRIVER   := `echo ${DRIVER:-"qemu"}`
export FILENAME	:= `echo ${FILENAME:-"cloud-init.yml"}`
export MEM		:= `echo ${MEM:-"4G"}`
export PLAY     := `echo ${PLAY:-"hardening.yml"}`
export VM		:= `echo ${VM:-"testvm"}`

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
update-deps args=CWD:
	#!/usr/bin/env bash
	# set -euxo pipefail
	args=$(realpath {{args}})
	find "${args}" -maxdepth 3 -name "pyproject.toml" -exec \
		echo "[{}]" \; -exec \
		echo "Clearing pypi cache..." \; -exec \
		poetry --directory "${args}" cache clear --all pypi --no-ansi \; -exec \
		poetry --directory "${args}" update --lock --no-ansi \;

# [deps]     export requirements.txt
export-reqs args=CWD: update-deps
	#!/usr/bin/env bash
	# set -euxo pipefail
	args=$(realpath {{args}})
	find "${args}" -maxdepth 3 -name "pyproject.toml" -exec \
		echo "[{}]" \; -exec \
		echo "Exporting requirements.txt..." \; -exec \
		poetry --directory "${args}" export --no-ansi --without-hashes --output requirements.txt \;

# [git]      update pre-commit hooks
pre-commit:
    @echo "To install pre-commit hooks:"
    @echo "pre-commit install -f"
    @echo "Updating pre-commit hooks..."
    pre-commit autoupdate

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
	-w="/app" \
	{{APP}} \
	devel schema --config-file {{FILENAME}}

# [check]    validate instance-data.json
check-id:
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
	--name {{APP}} \
	-h ${HOST:-localhost} \
	-v $(pwd):/app \
	-v $(pwd)/cloud-init:/run/cloud-init \
	-v $(pwd)/instance:/var/lib/cloud/instance \
	-w="/app" \
	{{APP}} \
	query --list-keys /run/cloud-init/instance-data.json

# [ansible]  run ansible playbook
ansible: start
	#!/usr/bin/env bash
	# set -euxo pipefail
	multipass exec {{VM}} -- \
	cd /home/ubuntu/git/ansible-role-hardening/tasks \
	&& ansible-playbook hardening.yml -i /etc/ansible/hosts
