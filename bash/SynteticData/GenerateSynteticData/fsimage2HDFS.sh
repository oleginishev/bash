#!/bin/bash
HDFS_PATH="/opt/cloudera/parcels/CDH-6.3.1-1.cdh6.3.1.p0.1470567/bin"
DIR_TO_FILE="/data2/fsimage"
DATE="$(date '+%Y%m%d')"
FILE=fsimage_$DATE.csv
LOGSTASH=hostname:port
SUUSER=hdfs
HDFSPASS=""

echo $HDFSPASS | su - $SUUSER  -c "/usr/bin/kdestroy -A"
echo $HDFSPASS | su - $SUUSER  -c "echo $HDFSPASS | /usr/bin/kinit"

postMessageToLogstash() {
    CURL_DATA={\"app_id\":\"pad-fsimage2hdfs\",\"type_id\":\"json\",\"message\":\"$1\"}
    #echo $1
    /usr/bin/curl --header "Content-Type: application/json" --request POST --data "$CURL_DATA" $LOGSTASH > /dev/null 2>&1
}

fsimage2hdfs() {
    SLICE1="$(ls -l $DIR_TO_FILE/$FILE  | awk '{print $5}')"
    sleep 5
    SLICE2="$(ls -l $DIR_TO_FILE/$FILE  | awk '{print $5}')"

    if [[ "$SLICE1" -eq "$SLICE2" ]]
    then
        postMessageToLogstash "[fsimage2hdfs.sh] EQ. Source file is completely copied"
        DESTHDFS=$(echo $HDFSPASS | su - $SUUSER  -c "$HDFS_PATH/hdfs dfs -test -e /fsimage/od/dt=$DATE/fsimage.csv; echo \$?" | tail -n 1)
        echo $DESTHDFS
        if [ "$DESTHDFS" == "0" ]; then
            echo "IN HDFS EXIST"
            postMessageToLogstash "[fsimage2hdfs.sh] Destinanion HDFS file exists"
        else
            echo "IN HDFS NOT EXIST"
            postMessageToLogstash "[fsimage2hdfs.sh] Destinanion HDFS file not found"
            echo $HDFSPASS | su - $SUUSER  -c "$HDFS_PATH/hdfs dfs -mkdir -p /fsimage/od/dt=$DATE"
            echo $HDFSPASS | su - $SUUSER  -c "$HDFS_PATH/hdfs dfs -put $DIR_TO_FILE/$FILE /fsimage/od/dt=$DATE/fsimage.csv"
        fi
    else
        postMessageToLogstash "[fsimage2hdfs.sh] NOT EQ. Source file is not fully copied"
    fi
}

if [ ! -f "$DIR_TO_FILE/${FILE}_tmp" ]; then
    echo "[fsimage2hdfs.sh] Source file not found"
    echo $HDFSPASS | su - $SUUSER  -c "$HDFS_PATH/hdfs dfsadmin -fetchImage $DIR_TO_FILE/${FILE}_tmp"
    echo $HDFSPASS | su - $SUUSER  -c "$HDFS_PATH/hdfs oiv -i $DIR_TO_FILE/${FILE}_tmp -o $DIR_TO_FILE/$FILE -p Delimited"

    echo "[fsimage2hdfs.sh] Source file exists"
    fsimage2hdfs
else
    echo "[fsimage2hdfs.sh] Source file exists"
    fsimage2hdfs
fi
