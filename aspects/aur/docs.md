
# Virtual Machine Manager

- Inside "Show virtual hardware details"
  - Memory->Enable shared memory

# Arch Installation

```bash

# load german keyboard layout
loadkeys de

# virtiofs mount in VM guest
sudo mount -t virtiofs dotfiles /mnt
ln -sfn /mnt ~/.dotfiles

```
