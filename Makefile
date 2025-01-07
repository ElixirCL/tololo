.PHONY: antora.build antora.server antora.docker.build antora.bash

antora.docker.build adb:
	@docker build -t local/antora:tololo priv/docs/.

antora.build ab:
	@cp priv/docs/modules/ROOT/pages/index.adoc README.adoc
	@rm -rf docs/
	@docker run -u $(id -u):$(id -g) -v .:/antora:Z --rm -t local/antora:tololo antora-playbook.yml
	
antora.server as:
	@make antora.build
	@cd docs && python3 -m http.server

antora.bash ash:
	@docker run -u $(id -u):$(id -g) -v .:/antora:Z --rm -it local/antora:tololo ash