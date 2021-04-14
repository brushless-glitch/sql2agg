#!/bin/bash

IFS=''
cat $1 | while read -r line ; do
    if [ "$(sed 's/^ *//' <<<${line})" == '<script src="bundle.js"></script>' ] ; then
        echo "<script>"
        cat src/bundle.js
        echo "</script>"
    else
        echo "$line"
    fi
done > $2

