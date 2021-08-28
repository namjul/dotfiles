

.PHONY: install

# TODO asdf, brew, nvim

install:
	@echo "Creating symlinks"
	stow -v dots
	@echo "Installing dotfiles..."

