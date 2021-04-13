all: test build

.PHONY: build
build: src/sql_parser.js

.PHONY: test
test: src/parser.js src/sql_parser.js src/sql2agg.js
	node src/sql2agg.js test/test1.sql

src/sql_parser.js: src/sql_parser.jison
	jison src/sql_parser.jison --outfile src/sql_parser.js

