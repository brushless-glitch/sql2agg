IFS=''
while read -r line ; do
    if [ "$(echo $line | sed 's/^ *//')" == '<script src="bundle.js"></script>' ] ; then
        echo "<script>"
        cat src/bundle.js
        echo "</script>"
    else
        echo "$line"
    fi
done

