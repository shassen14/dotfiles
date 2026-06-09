.PHONY: install update push apply diff obs-save obs-apply help

help: ## Show all targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

install: ## Full bootstrap (./bootstrap.sh)
	./bootstrap.sh

update: ## Pull remote changes and apply (chezmoi update)
	chezmoi update

sync: ## Re-add changed files locally (chezmoi re-add)
	chezmoi re-add

apply: ## Apply dotfiles verbosely (chezmoi apply -v)
	chezmoi apply -v

diff: ## Preview pending changes (chezmoi diff)
	chezmoi diff

obs-save: ## Save live OBS config to dotfiles repo
	chezmoi add ~/.config/obs-studio

obs-apply: ## Restore OBS config from dotfiles repo to ~/.config/obs-studio
	cp -r $(shell chezmoi source-path)/home/private_dot_config/obs-studio ~/.config/obs-studio
