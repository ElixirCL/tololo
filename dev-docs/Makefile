.PHONY: html server sql install bash

html h:
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ tololo-dev-docs asciidoctor -r asciidoctor-diagram README.adoc -o docs/index.html --verbose


server s:
	@cd docs && echo "http://localhost:8000" && python3 -m http.server

sql:
	node node_modules/@dbml/cli/bin/dbml2sql.js database/database.dbml --postgres --out-file database/database.sql

bash:
	@docker run -it -u $(id -u):$(id -g) -v .:/documents/ tololo-dev-docs /bin/bash

install i:
#docker pull schemacrawler/schemacrawler
	@docker build -t tololo-dev-docs .
