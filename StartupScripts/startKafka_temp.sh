#!/bin/bash

./bin/zookeeper-server-start.sh config/zookeeper.properties > logs/zk.logs 2>&1 & 

echo "Started ZK, sleeping for 3 secs"

sleep 3s

./bin/kafka-server-start.sh config/server.properties > logs/kafka-server.log 2>&1 &

sleep 5s

echo "Creating topic spark-test-partioned"

./bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 4 --topic spark-test-partioned

sleep 5s

echo "Listing topics"

./bin/kafka-topics.sh --list --zookeeper localhost:2181

