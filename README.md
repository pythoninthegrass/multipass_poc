# multipass_poc

Use Ansible and Multipass to setup a local Kubernetes (k3s) cluster.

## Setup
* Install [homebrew](https://brew.sh/)
* Install [asdf](https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies)
* Install [python](https://github.com/danhper/asdf-python)
* Install [pipx](https://pypa.github.io/pipx/#install-pipx)
* Install [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-pip)
* Install [multipass](https://multipass.run/)

## Usage
* Edit the `templates/cloud-init-template.j2` file to your heart's content. Can add nodes, change hardware provisioning, Ubuntu version, etc.
* Run a sanity check via `ansible-playbook main-playbook.yml --check`
* Assuming no errors occur, re-run the playbook without the dry-run flag: `ansible-playbook main-playbook.yml`
* Basic multipass commands
    ```bash
    # launch instance
    multipass launch --name foo

    # cloud-init
    multipass launch -n bar --cloud-init cloud-config.yaml

    # see instances
    multipass list

    # ssh
    multipass shell foo

    # run commands
    multipass exec foo -- lsb_release -a

    # start/stop instances
    multipass <start|stop> foo bar

    # stop _all_ instances
    multipass stop --all

    # cleanup
    multipass delete bar
    multipass purge

    # find alternate images
    λ multipass find
    Image                       Aliases           Version          Description
    18.04                       bionic            20220523         Ubuntu 18.04 LTS
    20.04                       focal,lts         20220505         Ubuntu 20.04 LTS
    21.10                       impish            20220309         Ubuntu 21.10
    22.04                       jammy             20220506         Ubuntu 22.04 LTS
    anbox-cloud-appliance                         latest           Anbox Cloud Appliance
    charm-dev                                     latest           A development and testing environment for charmers
    docker                                        latest           A Docker environment with Portainer and related tools
    minikube                                      latest           minikube is local Kubernetes

    # rtfm
    multipass help <command>
    ```

## TODO
* Setup `$KUBECONFIG`
* [terraform multipass provider](https://github.com/roiterorh/multipass-terraform)
* Customize cloud-init image
  * Maybe add Fedora or other distros
* Refactor kludgey variables
* Switch to either k0s or rancher instead of multipass

## Further reading
[Creating Multipass Virtual Machines with Ansible – The Blog of Ivan Krizsan](https://www.ivankrizsan.se/2021/10/10/creating-multipass-virtual-machines-with-ansible/)

[Use Linux Virtual Machines with Multipass | by Andrew Zhu | CodeX | Medium](https://medium.com/codex/use-linux-virtual-machines-with-multipass-4e2b620cc6)

[Cloud config examples — cloud-init 22.2 documentation](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)

[Adding Users | Ansible Tutorials](https://www.ansibletutorials.com/adding-users)

[6 troubleshooting skills for Ansible playbooks | Enable Sysadmin](https://www.redhat.com/sysadmin/troubleshoot-ansible-playbooks)
