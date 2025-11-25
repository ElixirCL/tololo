.PHONY: docs docs.server dev.shell dev.services antora.deps antora.docs mix.docs mix.docs.publish mix.deps mix.setup mix.phoenix.server mix.credo mix.format
# Elixir Env
## Devenv Commands
dev.shell shell dsh:
	@devenv shell

dev.services services:
	@devenv up

## Mix commands
mix.docs mdoc:
	@cd eatsbot && mix docs
	@rm -rf docs/_dist/api
	@mkdir -p docs/_dist/
	@cp -R eatsbot/doc docs/_dist/api

mix.docs.publish mdp:
	@cd eatsbot && mix hex.publish

mix.phoenix.server mix.server mps:
	@cd eatsbot && iex -S mix phx.server | vector --config ../vector.yaml

mix.credo:
	@cd eatsbot && mix credo

mix.format:
	@cd eatsbot && mix format

mix.deps md:
	@cd eatsbot && mix deps.get

mix.setup ms:
	@cd eatsbot && mix archive.install hex phx_new
	@cd eatsbot && mix archive.install hex igniter_new
	@make mix.deps
	@cd eatsbot && mix ash.setup
	@cd eatsbot && mix setup

# Bruno
mix.gen.delivery mgd:
	@cd eatsbot && mix generate.delivery.env

# Antora Env
## Antora Docs
antora.docs adoc:
	@antora antora-playbook.yml

antora.deps adeps:
	@yarn install

# Docs
docs d:
	@rm -rf docs/_dist
	@make antora.docs
	@make mix.docs
	@touch docs/_dist/.nojekyll

docs.server ds:
	@npm run serve
