output="/tmp/extracted.h"
rm $output 2> /dev/null
touch $output

IFS=$'\n'
mode=""
for line in $(cat $1); do
    truncatedLine=$(echo "$line" | tr -d " ")

    if echo $truncatedLine | egrep "/*TYPEDEF" > /dev/null && echo $mode | grep -v "I" > /dev/null; then
        mode="I"
        echo "--- Type Def ---" >> $output
        continue
    fi

    if echo $truncatedLine | egrep "/*ENDTYPEDEF" > /dev/null; then
        mode=""
        break
    fi

    if echo $mode | grep "I" > /dev/null; then
        echo "$line" >> $output
    fi
done

if [ ! "$(cat $output)" == "" ]; then
    echo "" >> $output
fi

echo "--- Prototypes ---" >> $output

cat $1 | egrep -v "^(/|(typedef))" | egrep "^[a-Z].*\(" | sed "s/\ *{.*//g">> $output

cat $output
