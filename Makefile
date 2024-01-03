

.PHONY: install

# TODO mise, brew, nvim

install:
	@echo "Creating symlinks"
	stow -v dots
	@echo "Installing dotfiles..."

