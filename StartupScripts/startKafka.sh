#!/bin/bash

# OWNER : Abhay Dandekar
# SCRIPT : To manage start-up of KAFKA

source ./config

echo "Using INSTALL_HOME: $HDFS_INSTALL_HOME"

COMPONENT=KAFKA
COMPONENT_INSTALL_HOME=$KAFKA_INSTALL_HOME
COMPONENT_START_COMMAND="./bin/kafka-server-start.sh config/server.properties"
COMPONENT_LOG_FILE="logs/kafka-startup.log"
COMPONENT_GREP_TEST="Kafka"
COMPONENT_PRE_GREP_COUNT=0
COMPONENT_GREP_COUNT=1
#Check for ZK
COMPONENT_DEPENDENCY_GREP_TEST="QuorumPeerMain"
COMPONENT_DEPENDENCY_GREP_COUNT=1

COMPONENT_ACCESS_COMMAND="./bin/kafka-topics.sh --list --zookeeper localhost:2181"

if [ -z $COMPONENT_INSTALL_HOME ]
then
	echo "$COMPONENT 's INSTALL_HOME found empty"
	echo "Exiting ...."
	exit 1
fi

# PRECHECK for Kafka
PRE_PROCESS_COUNT=`jps | grep -c "$COMPONENT_GREP_TEST"`
if [ $COMPONENT_PRE_GREP_COUNT -ne $PRE_PROCESS_COUNT ]
then
        echo "Processes for $COMPONENT seems to be already started, pre-process count did not equal $COMPONENT_PRE_GREP_COUNT"
	echo "Below are the processes aleady running"
	jps
        echo "Exiting ..."
        exit 4
fi

#PRECHECK for Dependency ( Zookeeper )
DEPENDENCY_PROCESS_COUNT=`jps | grep -c "$COMPONENT_DEPENDENCY_GREP_TEST"`
if [ $COMPONENT_DEPENDENCY_GREP_COUNT -ne $DEPENDENCY_PROCESS_COUNT ]
then
        echo "Processes for $COMPONENT seems to be already started, pre-process count did not equal $COMPONENT_PRE_GREP_COUNT"
        echo "Below are the processes aleady running"
        jps
        echo "Exiting ..."
        exit 4
fi


echo "Starting $COMPONENT from $COMPONENT_INSTALL_HOME"
cd $COMPONENT_INSTALL_HOME

$COMPONENT_START_COMMAND > $COMPONENT_LOG_FILE 2>&1 &disown 
RET_CODE=$?
if [ $RET_CODE -ne 0 ];
then
	echo "WARN: return code of startup command was not 0"
fi

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
	echo "Something went wrong when accessing $COMPONENT"
	echo "Check the output above"
	exit 3
fi
