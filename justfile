# https://just.systems/man/en

# load .env
set dotenv-load

# # set env var
export APP		:= "cloud-conf"
export CONF		:= "cloud-init.yaml"
export ENTRY	:= "cloud-init.yaml"
export CPU		:= "2"
export MEM		:= "2G"
export DISK		:= "5G"
export VM		:= "testvm"

# x86_64/arm64
arch := `uname -m`

# # hostname
# host := `uname -n`

# # operating system
# os := `uname -s`

# # home directory
# home_dir := env_var('HOME')

# # docker-compose / docker compose
# # * https://docs.docker.com/compose/install/linux/#install-using-the-repository
# docker-compose := if `command -v docker-compose; echo $?` == "0" {
# 	"docker-compose"
# } else {
# 	"docker compose"
# }

# [halp]     list available commands
default:
	just --list

# [git]      update pre-commit hooks
pre-commit:
	@echo "To install pre-commit hooks:"
	@echo "pre-commit install"
	@echo "Updating pre-commit hooks..."
	pre-commit autoupdate

# [multipass]list multipass instances
list:
	multipass list

# [multipass]launch multipass instance
launch:
	multipass launch -n {{VM}} \
	--cpus {{CPU}} \
	--memory {{MEM}} \
	--disk {{DISK}} \
	--cloud-init {{CONF}} \
	-v

# [multipass]start multipass instance
start:
	multipass start {{VM}}

# [multipass]shell into multipass instance
shell: start
	multipass shell {{VM}}

# [multipass]stop multipass instance
stop:
	multipass stop {{VM}}

# [multipass]delete multipass instance
delete: stop
	multipass delete {{VM}}

# [multipass]purge multipass instance
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
