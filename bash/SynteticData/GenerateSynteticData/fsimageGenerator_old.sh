#!/bin/bash

USERNAME=("u_dc_s_vasechkin" "u_dc_s_tetyaev" "u_dc_s_ivanov" "u_dc_s_totoshkin" "u_dc_s_petrov" "u_dc_s_pushkarev" "smoktunovsky" "nikulin" "pankratovcher" "shalypin" "gaydar")
GENPATH=("tmp" "etc" "data" "usr" "var" "log" "mod" "data1" "data2" "opt" "bin" "home" "tmp" "core" "dwh" "slcl" "hist" "v" "agr" "cred" "collat" "ctl" "loading" "part00021" "96a8335e" "931e" "4bc8" "909d" "e4d051ed5b31" "c000" "snappy" "parquet")
INTNUMBER=("1" "2" "3" "4" "5" "6" "7" "8" "9")
GROUPNAME=("admin" "user" "balckuser" "downuser" "non-user" "ssluser" "piviuser" "mainuser" "vipuser")
PERMISSION=("---" "--x" "-w-" "-wx" "r--" "r-x" "rw-" "rwx")
DATE="$(date '+%Y%m%d')"
DIR_TO_FILE="/first_dir/second_dir"
FILE=filename_$DATE.csv

function generate_path {
        for i in {1..5}
        do
                GENPATH=${GENPATH[$RANDOM % ${#GENPATH[@]}]}
                RNDpath=$RNDpath/$GENPATH

        done
}

function generate_permission {
        for i in {1..3}
        do
               PERMISSION=${PERMISSION[$RANDOM  % ${#PERMISSION[@]}]}
               RNDpermission=$RNDpermission$PERMISSION
        done
}
function generate_json {
    # use generate path function
    generate_path
    generate_permission
    # seed random generator
    RANDOM=$(date +%N)
    # pick a random entry from the domain list to check against
    RNDusername=${USERNAME[$RANDOM % ${#USERNAME[@]}]}
    RNDgroupname=${GROUPNAME[$RANDOM % ${#GROUPNAME[@]}]}
    RNDblockscount=$((RANDOM%10+1))
    RNDdsquota=$((RANDOM%2+1))
    RNDnsquota=$((RANDOM%2+1))
    RNDreplication=$((RANDOM%3+1))
    RNDfilesize=$((RANDOM%1125899906842624+10))
    RNDpreferredblocksize=$((RANDOM%1125899906842624+10))
    RNDdt=$(date -d "$((RANDOM%1+2019))-$((RANDOM%12+1))-$((RANDOM%28+1))" '+%Y%m%d')
    RNDmodificationtime=$(date -d "$((RANDOM%1+2019))-$((RANDOM%12+1))-$((RANDOM%28+1)) $((RANDOM%23+1)):$((RANDOM%59+1)):$((RANDOM%59+1))" '+%d-%m-%Y %H:%M:%S')
    RNDaccesstime=$(date -d "$((RANDOM%1+2019))-$((RANDOM%12+1))-$((RANDOM%28+1)) $((RANDOM%23+1)):$((RANDOM%59+1)):$((RANDOM%59+1))" '+%d-%m-%Y %H:%M:%S')

    echo $RNDpath $RNDreplication $RNDmodificationtime $RNDaccesstime $RNDpreferredblocksize $RNDblockscount $RNDfilesize $RNDnsquota $RNDdsquota $RNDpermission $RNDusername $RNDgroupname >> $DIR_TO_FILE/$FILE
    unset RNDpath RNDreplication RNDmodificationtime RNDaccesstime RNDpreferredblocksize RNDblockscount RNDfilesize RNDnsquota RNDdsquota RNDpermission RNDusername RNDgroupname

}

rm -rf $DIR_TO_FILE/$FILE
#echo $DIR_TO_FILE/$FILE
touch $DIR_TO_FILE/$FILE
echo "Path    Replication     ModificationTime        AccessTime      PreferredBlockSize      BlocksCount     FileSize        NSQUOTA DSQUOTA Permission      UserName        GroupName" >> $DIR_TO_FILE/$FILE
for i in {1..100}
do
generate_json
#echo $JSON_STRING
done
