.PHONY: dev.shell dev.services antora.shell antora.deps antora.docs mix.docs mix.docs.publish mix.deps mix.setup mix.phoenix.server

# Elixir Env
## Devenv Commands
dev.shell shell dsh:
	@devenv shell

dev.services services ds:
	@devenv up

## Mix commands
mix.docs mdoc:
	@cd tololo && mix docs
	@cp -R tololo/doc docs/_dist/api

mix.docs.publish mdp:
	@cd tololo && mix hex.publish

mix.phoenix.server mix.server mps:
	@cd tololo && iex -S mix phx.server

mix.deps md:
	@cd tololo && mix deps.get

mix.setup ms:
	@cd tololo && mix archive.install hex phx_new
	@cd tololo && mix archive.install hex igniter_new
	@cd tololo && mix ash.setup
	@cd tololo && mix setup

# Antora Env
## Antora Docs
antora.shell ashell:
	@cd docs && make shell

antora.docs adoc:
	@cd docs && make build

antora.deps adeps:
	@yarn install