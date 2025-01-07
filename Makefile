.PHONY: antora.build antora.server dev.shell dev.services mix.deps mix.setup mix.phoenix.server

# Documentation Commands
antora.build ab:
	@cp priv/docs/modules/ROOT/pages/index.adoc README.adoc
	@rm -rf docs/
	@antora antora-playbook.yml
	
antora.server as:
	@make antora.build
	@cd docs && python3 -m http.server

# Devenv Commands
dev.shell dsh:
	@devenv shell

dev.services ds:
	@devenv up

# Mix commands
mix.phoenix.server mix.server mps:
	@cd tololo && iex -S mix phx.server

mix.deps md:
	@cd tololo && mix deps.get

mix.setup ms:
	@cd tololo && mix archive.install hex phx_new
	@cd tololo && mix archive.install hex igniter_new
	@cd tololo && mix ash.setup
	@cd tololo && mix setup
