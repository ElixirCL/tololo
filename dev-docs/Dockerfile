FROM asciidoctor/docker-asciidoctor:latest

RUN apk add --update neovim nodejs npm
RUN npm install -g @dbml/cli
RUN npm install -g @softwaretechnik/dbml-renderer


WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
