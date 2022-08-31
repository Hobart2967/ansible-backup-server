# Machine Provisioning for Backup Servers

This ansible project is for provisioning a bare metal Debian 11 box. It provides:

- Postfix relay client setup

- APF Firewall setup
- Fail2Ban, connected to:
  - PostFix, sending emails about bans
  - APF, the firewall configured.
- Setup of anacron backup jobs:
  - Backup of file systems
  - Coming soon: Backup of MySQL / MariaDB Databases
- Virtual Box Setup with multiple machines
- SSH Keys and Trust Relationships between SSH Servers

## Usage

### Prerequisites

#### Required Tools

| Name            | Version   |
| :-------------- | :-------- |
| Python  | ^3.0.0 |
| Pip | latest |
| Ansible | latest |

#### Workspace Preparation

##### Setting up your keepass vault

Create a new or download an existing keepass file to your hard drive. This file should contain users, passwords and servers needed for setting up the remote system connection between the database server and the provisioned one.

##### Setting up Ansible
```sh
python3 -m pip install --user ansible
```

### Run

```sh
./provision-machine.sh <hostname> <user> keepass_file.kdbx
```

## Infrastructural Dependencies

- Keepass Database, secured with a password. This one is used as key storage, hiding sensitive data from this repository.