.PHONY: antora.build antora.server bash deploy docker.build

docker.build db:
	@docker build -t local/antora:tololo priv/docs/.

antora.build ab:
	@rm -rf docs/
	@docker run -u $(id -u):$(id -g) -v .:/antora:Z --rm -t local/antora:tololo antora-playbook.yml
	
antora.server as:
	@make antora.build
	@cd docs && python3 -m http.server

bash sh:
	@docker run -u $(id -u):$(id -g) -v .:/antora:Z --rm -it local/antora:tololo ash