#!/bin/bash

if [ "$(which xmlstarlet)" == "" ] ; then
    echo "Must have xmlstarlet in order to build this project"
fi

IFS=''
cat src/index.html |
xmlstarlet edit --omit-decl --update "//textarea[@id='sql']" --value "$(< test/test1.sql)" |
while read -r line ; do
    if [[ ${line} =~ '<script id="bundle"' ]] ; then
        echo "<script>"
        cat src/bundle.js
        echo "</script>"
    else
        echo "$line"
    fi
done > build/sql2agg.html
