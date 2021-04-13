all: test build html

.PHONY: build
build: src/sql_parser.js

.PHONY: test
test: src/parser.js src/sql_parser.js src/sql2agg.js
	node src/sql2agg.js test/test1.sql

src/sql_parser.js: src/sql_parser.jison
	jison src/sql_parser.jison --outfile src/sql_parser.js

.PHONY: html
html: src/bundle.js build/sql2agg.html

src/bundle.js: src/index.js src/parser.js src/sql_parser.jison
	browserify src/index.js -o src/bundle.js

build/sql2agg.html: src/index.html src/bundle.js
	mkdir -p sql2agg/build
	scripts/package-js.sh <src/index.html >build/sql2agg.html


