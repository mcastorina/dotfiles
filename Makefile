# Uses stow to install and remove symlinks for dotfiles

# Configuration
STOW        ?= /usr/bin/stow
STOW_TARGET ?= $$HOME
STOW_DIR    ?= common
PROFILES     = $(shell find * -maxdepth 0 -type d)

all: $(STOW_DIR)
$(PROFILES): run
	$(STOW) --target=$(STOW_TARGET) $@

# If stow encounters a conflict that's a regular file, overwrites stow's
# version with the existing one, and creates a link
adopt:
	$(STOW) --target=$(STOW_TARGET) --adopt $(STOW_DIR)
# Removes the symlinks created by stow
clean: clean($(STOW_DIR))
clean(%):
	$(STOW) --delete --target=$(STOW_TARGET) $*

# Dummy rule to always run certain targets
run:

.phony: adopt clean run
