FROM asciidoctor/docker-asciidoctor:latest

RUN apk add --update nodejs npm
RUN npm install -g @dbml/cli
RUN npm install -g @softwaretechnik/dbml-renderer
RUN npm install -g @mermaid-js/mermaid-cli

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
