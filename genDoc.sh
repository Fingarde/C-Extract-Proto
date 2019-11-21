output="/tmp/compteRendu.txt"
rm $output 2> /dev/null
touch $output
echo "--- Compte rendu $1 ---" >> $output

IFS=$'\n'
mode=""
mode2=""
shift
for file in $@; do
    echo "" >> $output
    echo "--- Fichier $file ---" >> $output

    for line in $(cat $file); do
        truncatedLine=$(echo "$line" | tr -d " ")
        if echo "$truncatedLine" | egrep "/*TYPEDEF" > /dev/null && echo $mode | egrep -v "I" > /dev/null; then
            mode="I"
            continue
        fi

        if echo "$truncatedLine" | egrep "/*ENDTYPEDEF" > /dev/null; then
            mode=""
            continue
        fi

        if echo $mode | egrep "I" > /dev/null; then
            continue
        fi
        if echo $file | egrep -v ".*\.h" > /dev/null && echo "$line" | egrep -v "^(/|(typedef))" | egrep "^[a-Z].*\(" > /dev/null; then
            echo "" >> $output
            echo "/* Fonction $(echo "$line" | cut -d " " -f 2 | cut -d "(" -f 1)" >> $output
            for subLine in $(cat "$file"); do
                if [ "$subLine" == "$line" ]; then
                    mode2="I"
                    printf "\tFinalité: $(echo "$subLine" | tr -s "/" | cut -d "/" -f 2 | sed -e "s/\ *\(.*\)/\1/g")\n" >> $output
                    printf "\tVariables:\n" >> $output
                    continue
                fi

                if echo "$subLine" | egrep "^}" > /dev/null && echo $mode2 | egrep "I" > /dev/null; then
                    mode2=""
                    if echo "$subLine" | egrep -v "^}$"> /dev/null; then
                        printf "\tValeur Retournée: $(echo "$subLine" | sed -e "s/.*\/\ *//g")\n" >> $output
                    fi
                    break
                fi

                if echo $mode2 | egrep "I" > /dev/null && echo $subLine | grep "//" > /dev/null; then
                    printf "\t\t- $(echo "$subLine" | grep "/"  | sed -e "s/=.*\;/;/g" | sed -e "s/\ *\(.*\)/\1/g" | tr -s " " | cut -d " " -f 2- | sed -e "s/;\ *\/\//:/g")\n" | sed -e "s/\[.*\]//g" >> $output
                fi
            done
            echo "*/" >> $output
        fi

        echo "$line" | sed -e "s/\/.*$//g">> $output
    done
done

cat $output
