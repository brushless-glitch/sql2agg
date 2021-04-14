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

src/bundle.js: src/index.js src/parser.js src/sql_parser.js
	browserify src/index.js -o src/bundle.js

build/sql2agg.html: src/index.html src/bundle.js
	mkdir -p build
	scripts/package-js.sh src/index.html build/sql2agg.html

.PHONY: release
release: docs/index.html

docs/index.html: build/sql2agg.html
	mkdir -p docs
	cp build/sql2agg.html docs/index.html

.PHONY: clean
clean:
	rm -f src/bundle.js src/sql_parser.js build/sql2agg.html 

