#!/bin/bash
# Publish dummy application event messages to queue

for i in {1..10}
do
    echo "{\"event_id\":$i,\"action\":\"orders.update.completed\",\"process\":\"Restaurant\",\"order_id\":$i,\"restaurant_id\":$i,\"order_status\":\"ready\",\"timestamp\":\"2023-04-05T13:42:41\"}" \
        | rabbitmqadmin --username=guest --password=guest publish exchange="orders.exchange" routing_key="events.order_event.store"
done