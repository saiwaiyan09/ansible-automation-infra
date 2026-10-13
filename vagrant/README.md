# Vagrant implementation

This directory contains the original local VM lab. Vagrant defines two Ubuntu
24.04 virtual machines in VirtualBox; Ansible configures the Dashboard and
Counting applications as systemd services. The machines communicate over a
host-only private network.

## Architecture

| VM | Private IP | Application | Port |
| --- | --- | --- | --- |
| `dashboard` | `192.168.56.11` | Dashboard API/UI (`dashboard-api.service`) | 9002 |
| `counting` | `192.168.56.12` | Counting API (`counting-api.service`) | 9003 |

The Dashboard calls Counting at `192.168.56.12:9003`. The Vagrantfile uses the
`bento/ubuntu-24.04` box and disables the synced project folder. These
addresses belong to the local Vagrant lab; they are not the AWS instance
addresses.

## Requirements

- Vagrant
- Oracle VirtualBox
- Ansible installed on the host
- An SSH key pair for Vagrant-to-VM access

## Configure SSH public-key access

The Vagrantfile reads the public key from the path in
`VAGRANT_SSH_PUBLIC_KEY`. If unset, it defaults to
`~/.ssh/id_ed25519.pub`. Create or select a dedicated public key on the host,
and do not place the private key in this repository.

For example, select a key explicitly when starting Vagrant:

```bash
cd vagrant
export VAGRANT_SSH_PUBLIC_KEY="$HOME/.ssh/id_ed25519.pub"
vagrant validate
vagrant up
```

The public key is appended to the `vagrant` account's `authorized_keys` on
each VM. Ansible uses the paired private key. Edit
[`inventories/hosts.ini`](inventories/hosts.ini) and set
`ansible_ssh_private_key_file` to the absolute path of that private key on
your own host. Do not copy the private key into the VM or commit it. The
inventory in a local checkout may need this machine-specific setting replaced
before use.

## Run the original Ansible playbook

Run from the `vagrant/` directory after configuring the inventory and
starting both VMs. Syntax-check the playbook before executing it:

```bash
ansible-playbook -i inventories/hosts.ini playbooks/site.yml --syntax-check
ansible-playbook -i inventories/hosts.ini playbooks/site.yml
```

The playbook installs required Ubuntu packages, downloads the Linux `amd64`
Dashboard and Counting demo binaries, installs systemd unit files from
`playbooks/templates/`, and enables and starts both services.

Check that Ansible can reach both VMs:

```bash
ansible all -i inventories/hosts.ini -m ansible.builtin.ping
```

Check the services and open the Dashboard from the host:

```bash
ansible dashboard -i inventories/hosts.ini -b \
  -m ansible.builtin.command -a "systemctl is-active dashboard-api"
ansible counting -i inventories/hosts.ini -b \
  -m ansible.builtin.command -a "systemctl is-active counting-api"
```

Open <http://192.168.56.11:9002> in a browser. The optional host-side
endpoints are `http://192.168.56.11:9002` and
`http://192.168.56.12:9003`.

To stop the VMs without removing them, run `vagrant halt` from this directory.
Review the Vagrant documentation before destroying VMs or other local
resources.
