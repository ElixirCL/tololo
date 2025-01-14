.PHONY: antora.build antora.server shell

shell s:
	@devenv shell

antora.build b:
	@rm -rf ./_dist
	@antora ../antora-playbook.yml
	@touch ./_dist/.nojekyll

antora.server as:
	@make antora.build
	@npm run serve