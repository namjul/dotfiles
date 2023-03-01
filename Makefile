

.PHONY: install

# TODO rtx, brew, nvim

install:
	@echo "Creating symlinks"
	stow -v dots
	@echo "Installing dotfiles..."

