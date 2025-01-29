.PHONY: docs docs.server dev.shell dev.services antora.deps antora.docs mix.docs mix.docs.publish mix.deps mix.setup mix.phoenix.server

# Configure if you want Telegram (Use BotFather)
TELEGRAM_TOKEN=7674214898:AAHFT_5NVinmuWfbWi1DB1cMNkpIIlCqZvE
# Use ngrok http 4000 (or similar ssh tunnel command)
TELEGRAM_WEBHOOK=https://a937-2800-150-14a-2188-1549-101c-2dc7-a5c2.ngrok-free.app/updates_hook

# Elixir Env
## Devenv Commands
dev.shell shell dsh:
	@devenv shell

dev.services services:
	@devenv up

## Mix commands
mix.docs mdoc:
	@cd tololo && mix docs

mix.docs.publish mdp:
	@cd tololo && mix hex.publish

mix.phoenix.server mix.server mps:
	@cd tololo && iex -S mix phx.server

mix.deps md:
	@cd tololo && mix deps.get

mix.setup ms:
	@cd tololo && mix archive.install hex phx_new
	@cd tololo && mix archive.install hex igniter_new
	@make mix.deps
	@cd tololo && mix ash.setup
	@cd tololo && mix setup

# Bruno
mix.gen.delivery mgd:
	@cd tololo && mix generate.delivery.env

# Telegram
mix.telegram.server mts:
	@cd tololo && TELEGRAM_TOKEN=${TELEGRAM_TOKEN} TELEGRAM_WEBHOOK=${TELEGRAM_WEBHOOK} iex -S mix phx.server

# Antora Env
## Antora Docs
antora.docs adoc:
	@antora antora-playbook.yml

antora.deps adeps:
	@yarn install

# Docs
docs d:
	@rm -rf docs/_dist
	@make mix.docs
	@make antora.docs
	@cp -R tololo/doc docs/_dist/api
	@touch docs/_dist/.nojekyll

docs.server ds:
	@npm run serve
