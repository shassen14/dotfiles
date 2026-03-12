.PHONY: install update push apply diff help

help: ## Show all targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

install: ## Full bootstrap (./bootstrap.sh)
	./bootstrap.sh

update: ## Pull remote changes and apply (chezmoi update)
	chezmoi update

push: ## Re-add changed files, commit, and push to remote
	chezmoi re-add && chezmoi cd && git add -A && git commit -m "update" && git push

apply: ## Apply dotfiles verbosely (chezmoi apply -v)
	chezmoi apply -v

diff: ## Preview pending changes (chezmoi diff)
	chezmoi diff
