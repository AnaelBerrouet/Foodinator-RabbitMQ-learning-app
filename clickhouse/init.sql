CREATE DATABASE IF NOT EXISTS dw;

USE dw;

CREATE TABLE IF NOT EXISTS rabbitmq_events_queue
(
    event_id UInt32,
    action String,
    process String,
    order_id UInt32,
    restaurant_id UInt32,
    order_status String,
    timestamp DateTime,
) ENGINE = RabbitMQ SETTINGS
    rabbitmq_host_port = '127.0.0.1:5672',
    rabbitmq_exchange_name = 'orders.exchange',
    rabbitmq_routing_key_list = 'events.#',
    rabbitmq_format = 'JSONEachRow',
    rabbitmq_exchange_type = 'topic',
    rabbitmq_num_consumers = 1
    ;
    -- rabbitmq_address = 'amqp://guest:guest@localhost',
    -- rabbitmq_host_port = 'localhost:5672',
    -- rabbitmq_address = 'amqp://guest:guest@localhost:5672',

CREATE TABLE IF NOT EXISTS events (
    event_id UInt32,
    action String,
    process String,
    order_id UInt32,
    restaurant_id UInt32,
    order_status String,
    timestamp DateTime,
) Engine = MergeTree() ORDER BY event_id;

CREATE MATERIALIZED VIEW IF NOT EXISTS events_consumer
TO events AS
SELECT event_id, action, process, order_id, restaurant_id, order_status, timestamp
FROM rabbitmq_events_queue;