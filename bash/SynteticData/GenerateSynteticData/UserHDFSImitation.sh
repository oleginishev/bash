#!/bin/bash

HDFS_PATH="/usr/hdp/3.1.4.0-315/hadoop/bin"
ACTION=("create" "edit" "delete")
GENERATEFILE=genFile.csv
PREPATH="project"
#INPUT=./test2.csv
INPUT=./test2.csvBACK2
OLDIFS=$IFS
IFS=';'
arrdir1=()
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read  dir1 dir2 dir3 dir4 dir5 col6 col7
do
    column0+=($col0)
    arrdir1+=($dir1)
    arrdir2+=($dir2)        
    arrdir3+=($dir3)
    arrdir4+=($dir4)
    arrdir5+=($dir5)
    column6+=($col6)
    column7+=($col7)

done < $INPUT
IFS=$OLDIFS

echo " "

function edit_file() {
    COL7COUNT=${#column7[@]}


    let "SIZE = $RANDOM * 1024"
    if [ $COL7COUNT -ge 1 ]; then
        EDITFILE=${column7[$RANDOM % ${#column7[@]}]}

        SUUSER=$(echo $EDITFILE | cut -f1 -d:)
        FULLPATH=$(echo $EDITFILE | cut -f2 -d:)

        echo EDIT FILE IS
        echo $FULLPATH
        echo BY USER
        echo $SUUSER

   su - $SUUSER -c "/usr/bin/kdestroy -A"
   echo "Qwerty12" | su - $SUUSER  -c "/usr/bin/kinit"
   base64 /dev/urandom | head -c 1000 | su - $SUUSER -c "$HDFS_PATH/hadoop fs -appendToFile - $FULLPATH"
   fi


}

function create_file() {

    FULLPATH=$1
    SUUSER=$2

    let "SIZE = $RANDOM * 1024"
    echo "$SUUSER"
    su - $SUUSER -c "/usr/bin/kdestroy -A"
    echo "Qwerty12" | su - $SUUSER  -c "/usr/bin/kinit"
    su - $SUUSER -c "$HDFS_PATH/hdfs dfs -mkdir -p $(dirname $FULLPATH)"
    base64 /dev/urandom | head -c 1000 | su - $SUUSER -c "$HDFS_PATH/hadoop fs -appendToFile - $FULLPATH"

    echo "BY USER" $SUUSER
    echo "WAS CREATED " $FULLPATH


}

function delete_file() {

   COL7COUNT=${#column7[@]}

    if [ $COL7COUNT -ge 3 ]; then
        DELETEFILE=${column7[$RANDOM % ${#column7[@]}]}
        column7=( "${column7[@]/$DELETEFILE}" )
        SUUSER=$(echo $EDITFILE | cut -f1 -d:)
        FULLPATH=$(echo $EDITFILE | cut -f2 -d:)

        su - $SUUSER -c "$HDFS_PATH/hdfs dfs -rm -r -f  $FULLPATH"

        awk -F";" '{for(i=1;i<=NF;i++)if(i!=x)f=f?f FS $i:$i;print f;f=""}' x=7 ./test2.csvBACK2 > ./test2.tmp && mv ./test2.tmp  ./test2.csvBACK2
        awk -va="$(echo "${column7[@]}")" 'BEGIN{OFS=FS=";"; split(a,b," ")}{print $0,b[NR]}' ./test2.csvBACK2  >  ./test2.tmp && mv ./test2.tmp  ./test2.csvBACK2



        echo DELETED FILE IS
        echo $DELETEFILE


    fi

}

function generate_path {
  RANDOMMY=$((RANDOM%4+1))
    for ((i=0; i<=2; i++))
    do


        SUUSER=${column6[$RANDOM % ${#column6[@]}]}
        DIR1=${arrdir1[$RANDOM % ${#arrdir1[@]}]}
        DIR2=${arrdir2[$RANDOM % ${#arrdir2[@]}]}
        DIR3=${arrdir3[$RANDOM % ${#arrdir3[@]}]}
        DIR4=${arrdir4[$RANDOM % ${#arrdir4[@]}]}
        DIR5=${arrdir5[$RANDOM % ${#arrdir5[@]}]}


        if [[ $RANDOMMY -eq 1 ]];
            then
                FULLPATH=/$PREPATH/$DIR1/$GENERATEFILE
                #printf "$host\t$(date)\tTime Taken to checkout\t$Time_checkout\n" >> log.csv

                ### Full Path Plus Name
                FPPN=$SUUSER:$FULLPATH
                create_file "$FULLPATH" "$SUUSER"
                arrdir7+=($FPPN)
        fi

        if [[ $RANDOMMY -eq 2 ]];
            then
                FULLPATH=/$PREPATH/$DIR1/$DIR2/$GENERATEFILE
         #       echo $FULLPATH
                FPPN=$SUUSER:$FULLPATH
                create_file "$FULLPATH" "$SUUSER"
                arrdir7+=($FPPN)
        fi

        if [[ $RANDOMMY -eq 3 ]];
            then
                FULLPATH=/$PREPATH/$DIR1/$DIR2/$DIR3/$GENERATEFILE
          #      echo $FULLPATH
                FPPN=$SUUSER:$FULLPATH
                create_file "$FULLPATH" "$SUUSER"
                arrdir7+=($FPPN)

        fi

        if [[ $RANDOMMY -eq 4 ]];
            then
                FULLPATH=/$PREPATH/$DIR1/$DIR2/$DIR3/$DIR4/$GENERATEFILE
         #       echo $FULLPATH
                FPPN=$SUUSER:$FULLPATH
                create_file "$FULLPATH" "$SUUSER"
                arrdir7+=($FPPN)

        fi
    done

column7=("${column7[@]}" "${arrdir7[@]}")

#echo "NEW COLUMN7"
#printf '%s\n' "${column7[@]}"

awk -F";" '{for(i=1;i<=NF;i++)if(i!=x)f=f?f FS $i:$i;print f;f=""}' x=7 ./test2.csvBACK2 > ./test2.tmp && mv ./test2.tmp  ./test2.csvBACK2
awk -va="$(echo "${column7[@]}")" 'BEGIN{OFS=FS=";"; split(a,b," ")}{print $0,b[NR]}' ./test2.csvBACK2  >  ./test2.tmp && mv ./test2.tmp  ./test2.csvBACK2

}


function generate_action() {
    ACTION=$1

    if [[ "$ACTION" = "random" ]];
        then
           echo "RANDOM"
           ACTION=${ACTION[$RANDOM % ${#ACTION[@]}]}


    fi

    if [[ "$ACTION" = "create"  ]] ;
        then
            echo "CREATE"
            generate_path
    fi

    if [[ "$ACTION" = "edit"  ]] ;
        then
            echo "EDIT"
            edit_file
    fi

    if [[ "$ACTION" = "delete"  ]] ;
        then
            echo "DELETE"
            delete_file
    fi

}

generate_action $1