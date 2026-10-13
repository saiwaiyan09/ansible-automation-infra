# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2026-10-13

### Added

- Terraform configuration for AWS infrastructure provisioning.
- An AWS Ansible Controller EC2 instance.
- A public Ansible Controller EC2 instance and private Dashboard and Counting
  EC2 instances, as configured in Terraform.
- Public and internal Application Load Balancers.
- Ansible automation for application preparation and deployment.
- systemd service configuration for the Dashboard and Counting applications.
- Reusable Ansible inventory and group variable examples.
- AWS application demonstration screenshot.

### Changed

- Reorganized the Vagrant implementation under `vagrant/`.
- Made the Vagrant SSH public-key path configurable through
  `VAGRANT_SSH_PUBLIC_KEY`.
- Improved the project structure to separate AWS and Vagrant implementations.

## [v1.0.0]

The original local infrastructure automation release using Vagrant, VirtualBox,
Ubuntu 24.04 virtual machines, and Ansible. It deployed the Dashboard and
Counting applications as systemd services on separate VMs.

[v2.0.0]: https://github.com/saiwaiyan09/ansible-automation-infra/releases/tag/v2.0.0
[v1.0.0]: https://github.com/saiwaiyan09/ansible-automation-infra/releases/tag/v1.0.0
