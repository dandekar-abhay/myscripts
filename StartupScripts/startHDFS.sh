#!/bin/bash

source ./config

echo "Using INSTALL_HOME: $HDFS_INSTALL_HOME"

COMPONENT=HDFS
COMPONENT_INSTALL_HOME=$HDFS_INSTALL_HOME
COMPONENT_START_COMMAND="./sbin/start-dfs.sh"
COMPONENT_LOG_FILE="logs/hdfs.log"
COMPONENT_GREP_TEST="NameNode\|SecondaryNameNode\|DataNode"
COMPONENT_PRE_GREP_COUNT=0
COMPONENT_GREP_COUNT=3

COMPONENT_ACCESS_COMMAND="hdfs dfs -ls /"

if [ -z $COMPONENT_INSTALL_HOME ]
then
	echo "$COMPONENT 's INSTALL_HOME found empty"
	echo "Exiting ...."
	exit 1
fi

# PRECHECK 
PRE_PROCESS_COUNT=`jps | grep -c "$COMPONENT_GREP_TEST"`
if [ $COMPONENT_PRE_GREP_COUNT -ne $PRE_PROCESS_COUNT ]
then
        echo "Processes for $COMPONENT seems to be already started, pre-process count did not equal $COMPONENT_PRE_GREP_COUNT"
	echo "Below are the processes aleady running"
	jps
        echo "Exiting ..."
        exit 4
fi


echo "Starting HDFS from $COMPONENT_INSTALL_HOME"
cd $COMPONENT_INSTALL_HOME

$COMPONENT_START_COMMAND > $COMPONENT_LOG_FILE 2>&1 &

echo "Started $COMPONENT ... Awaiting $COMPONENT start-up for $GLOBAL_SLEEP_TIME secs"

sleep $GLOBAL_SLEEP_TIME

# Test process count
PROCESS_COUNT=`jps | grep -c "$COMPONENT_GREP_TEST"`

if [ $COMPONENT_GREP_COUNT -ne $PROCESS_COUNT ]
then
	echo "Processes for $COMPONENT did not start successully, process count did not equal $COMPONENT_GREP_COUNT"
	echo "Exiting ..."
	exit 2
fi

# Test access
$COMPONENT_ACCESS_COMMAND
RET_CODE=$?

if [ $RET_CODE -ne 0 ];
then
	echo "Something went wrong when accessing HDFS"
	echo "Check the output above"
	exit 3
fi
