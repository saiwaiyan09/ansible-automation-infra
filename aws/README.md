# AWS implementation

This directory contains the Terraform configuration for the AWS environment,
the Ansible configuration for the application instances, and the Dashboard
demonstration screenshot. The project is a technical demonstration, not a
production deployment.

## Architecture

Terraform provisions a custom VPC across two Availability Zones:

- Two public subnets, each associated with the public route table and Internet
  Gateway route.
- Two private subnets, each with a route through the NAT Gateway in its
  corresponding public subnet.
- One internet-facing Ansible Controller EC2 instance in a public subnet.
- One private Dashboard EC2 instance and one private Counting EC2 instance.
- An internet-facing public Application Load Balancer (ALB) and a private
  internal ALB.

The EC2 instances use the Amazon Linux 2023 x86-64 AMI obtained from the
AWS-managed Systems Manager parameter. The Dashboard and Counting instances
have no public IP address.

```text
Browser
  |
  | HTTP :80
  v
Public ALB (public subnets)
  |
  | HTTP :9002
  v
Dashboard EC2 (private subnet A)
  |
  | HTTP :9002
  v
Internal ALB (private subnets)
  |
  | HTTP :9003
  v
Counting EC2 (private subnet B)
```

The Dashboard's `COUNTING_SERVICE_URL` points to the internal ALB DNS name on
port 9002. The internal ALB listener forwards to its Counting target group on
port 9003. The public ALB listener is HTTP on port 80 and forwards to the
Dashboard target group on port 9002. Both target groups use an HTTP `/` health
check accepting status codes 200 through 399.

The security groups permit the ALB-to-target application traffic and SSH from
the controller to the private application instances. The controller's inbound
SSH source CIDR is a Terraform input. The public ALB security group currently
permits inbound HTTP on port 80 and HTTPS on port 443, but the Terraform
configuration only defines an HTTP listener; HTTPS/TLS termination is not
configured.

## Terraform resource organization

The Terraform root is [`terraform/`](terraform/). Resource definitions are
organized by infrastructure concern rather than nested modules:

| File | Resources and purpose |
| --- | --- |
| `vpc.tf` | VPC and DNS support |
| `subnets.tf` | Public and private subnets across the configured AZs |
| `internet-gateway.tf` | Internet Gateway |
| `public-route-tables.tf` | Public route table, default Internet Gateway route, and subnet associations |
| `nat.tf` | NAT Gateway Elastic IPs and NAT Gateways |
| `private-route-tables.tf` | Private routes through the corresponding NAT Gateways |
| `security.tf` | Security groups and ingress/egress rules for the ALBs, controller, and applications |
| `instances.tf` | Amazon Linux 2023 AMI lookup, controller and application EC2 instances, and Dashboard target attachment |
| `public-alb.tf` | Public ALB, HTTP listener, Dashboard target group, health check, and target attachment |
| `internal-alb.tf` | Internal ALB, listener on 9002, Counting target group on 9003, health check, and target attachment |
| `variables.tf` | AWS profile/region, key pair names, instance types, CIDRs, and AZ inputs/defaults |
| `versions.tf` | Terraform/provider requirements and AWS provider configuration |
| `outputs.tf` | Network, instance, ALB, and Dashboard URL outputs |

The configured AWS profile defaults to `main-console-admin`, and the region
defaults to `ap-southeast-1`; review [`terraform/variables.tf`](terraform/variables.tf)
and provide appropriate values for your own AWS account. The SSH CIDR for the
controller is required as an input.

### Terraform state safety

The checked-in Terraform source directory has no state file and no backend
block. Terraform execution must be connected to the correct state backend and
workspace for the target environment. In particular, do not run an apply
from a source-only GitHub checkout against the existing AWS infrastructure
without reconnecting it to the appropriate state. An unassociated state may
cause Terraform to propose duplicate resources or unintended changes.

Before any infrastructure operation, confirm the intended backend, workspace,
AWS account, and region. Review a plan against the correct state; do not treat
this source-only checkout as a replacement for the existing state.

## EC2 roles

The Terraform configuration creates three EC2 instances with distinct
networking purposes:

| Instance | Network placement | Purpose |
| --- | --- | --- |
| Ansible Controller | Public subnet A, public IP | Administrator SSH entry point and Ansible control host; reaches private instances over SSH |
| Dashboard | Private subnet A, no public IP | Serves the web dashboard on port 9002 |
| Counting | Private subnet B, no public IP | Serves the counting API on port 9003 |

Here, "role" describes each instance's function in the topology. The
configuration does not attach an EC2 IAM instance profile, and it does not
install/configure Ansible on the controller. Prepare the controller and its
Ansible runtime according to your environment before running the playbooks.

## Ansible Controller and SSH agent forwarding

The controller is the Ansible execution host; the private application
instances accept SSH from its security group. Use SSH agent forwarding so the
controller can authenticate to those instances without storing private keys
on it:

1. On the administrator workstation, start/use an SSH agent and add the
   application EC2 key (and the controller key if required by your local SSH
   setup). The private key remains on the workstation.
2. Connect to the controller with agent forwarding enabled:

   ```bash
   ssh-add /path/to/application-key.pem
   ssh -A -i /path/to/controller-key.pem ec2-user@CONTROLLER_PUBLIC_IP
   ```

   If the same key pair is used for both hops, add that key to the agent.
   Replace the example paths and address with local values.
3. On the controller, verify that the forwarded agent is available:

   ```bash
   ssh-add -l
   ```

4. Configure Ansible's SSH connection to forward the agent to managed hosts.
   For example, add this variable to the `[all:vars]` section of the working
   inventory:

   ```ini
   ansible_ssh_common_args='-o ForwardAgent=yes'
   ```

Never copy private SSH keys to the controller or commit them to the
repository. Restrict controller SSH ingress to a trusted administrator
address range.

## Configure the Ansible inventory

The sanitized inventory example is
[`ansible/inventory.ini.example`](ansible/inventory.ini.example). Configure
`ansible/inventory.ini` by substituting the Dashboard and Counting
**private** IPs from Terraform's outputs:

Replace the example addresses in `inventory.ini` with `dashboard_private_ip`
and `counting_private_ip`. Keep the configured user as `ec2-user` and Python
interpreter as `/usr/bin/python3`, unless the target environment requires
otherwise. Add the agent-forwarding variable shown above. Ensure the working
inventory is not committed if it contains environment-specific information.
If you create a separate working copy from the example, use a new filename
instead of overwriting an existing `inventory.ini`, and substitute that
filename in the commands below.

## Configure application variables

Copy the sanitized group variable example to Ansible's expected group-vars
filename:

```bash
cp group_vars/all.yml.example group_vars/all.yml
```

Edit `group_vars/all.yml`:

- `dashboard_port` is the Dashboard service port (9002).
- `counting_port` is the Counting service port (9003).
- Set `counting_service_url` to
  `http://<internal-alb-dns-name>:9002`, using the
  `internal_alb_dns_name` Terraform output.

The Dashboard systemd template injects that URL as
`COUNTING_SERVICE_URL`. Do not use the public ALB DNS name for this value; the
Dashboard-to-Counting path is through the internal ALB.

## Prepare and deploy applications

Run these commands from `aws/ansible` on the prepared controller after
configuring the inventory and variables. First syntax-check each playbook;
only then execute it against the intended hosts:

```bash
ansible-playbook -i inventory.ini playbooks/prepare.yml --syntax-check
ansible-playbook -i inventory.ini playbooks/deploy.yml --syntax-check

ansible-playbook -i inventory.ini playbooks/prepare.yml
ansible-playbook -i inventory.ini playbooks/deploy.yml
```

`prepare.yml` installs `wget`, `unzip`, `git`, and `jq` on both application
hosts. `deploy.yml` downloads the HashiCorp demo binaries, installs them under
`/usr/local/bin`, writes the corresponding systemd units from
`playbooks/templates/`, and enables and starts the services:

- `dashboard-api.service` runs `dashboard-service` as `ec2-user` on port 9002.
- `counting-api.service` runs `counting-service` as `ec2-user` on port 9003.

The deploy playbook also checks that the Counting service is active. Rerun
the syntax checks whenever you change playbook files, before running the
playbooks.

## Validate the application

On the controller, check each systemd service:

```bash
ansible dashboard -i inventory.ini -b \
  -m ansible.builtin.command -a "systemctl is-active dashboard-api"
ansible counting -i inventory.ini -b \
  -m ansible.builtin.command -a "systemctl is-active counting-api"
```

From a browser or an HTTP client that can reach the internet-facing ALB,
request the Dashboard URL:

```bash
curl -i http://<public-alb-dns-name>
```

The Dashboard should show a connected state and counter information. The
browser's WebSocket connection and the Dashboard's application request to
Counting use the internal ALB; validate the full interaction from the
Dashboard rather than trying to reach the private Counting instance directly.
The project screenshot is in [`assets/dashboard-result.png`](assets/dashboard-result.png).
