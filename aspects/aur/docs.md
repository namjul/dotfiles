
# Virtual Machine Manager

- Inside "Show virtual hardware details"
  - Memory->Enable shared memory

# Arch Installation

```bash

# load german keyboard layout
loadkeys de

# virtiofs mount in VM guest (any dest; default shown)
sudo mount -t virtiofs dotfiles /mnt
ln -sfn /mnt "${DOTFILES_DIR:-$HOME/.dotfiles}"

```
