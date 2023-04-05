#!/bin/bash
# Publish dummy messages to queue

for i in {1..10}
do
    TIMESTAMP=$(($(date +%s%N)))
    echo "{\"timestamp\":\"$TIMESTAMP\",\"id\":$i,\"body\":\"my body is $i\"}" \
        | rabbitmqadmin --username=guest --password=guest publish exchange=clickhouse-exchange routing_key=myqueue
done