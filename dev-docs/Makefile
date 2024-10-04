.PHONY: build sql

build b:
	asciidoctor README.adoc
	mv README.html index.html

sql:
	node node_modules/@dbml/cli/bin/dbml2sql.js database/database.dbml --postgres --out-file database/database.sql