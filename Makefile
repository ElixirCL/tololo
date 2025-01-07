.PHONY: antora.build antora.server dev.shell dev.services mix.deps mix.setup

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
mix.deps md:
	@mix deps.get

mix.setup ms:
	@mix setup
