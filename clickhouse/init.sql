DROP DATABASE IF EXISTS event;
CREATE DATABASE IF NOT EXISTS event;
USE event;

CREATE TABLE IF NOT EXISTS event (
    `timestamp` DateTime,
    `id` UInt32,
    `body` String
) Engine = Memory;

CREATE TABLE IF NOT EXISTS rabbitmq_entry
(
    `timestamp` UInt64,
    `id` UInt32,
    `body` String
) ENGINE = RabbitMQ SETTINGS
    rabbitmq_host_port = 'rabbitmq:5672',
    rabbitmq_exchange_name = 'clickhouse-exchange',
    rabbitmq_routing_key_list = 'myqueue',
    rabbitmq_format = 'JSONEachRow',
    rabbitmq_exchange_type = 'fanout',
    rabbitmq_num_consumers = 1,
    rabbitmq_routing_key_list = 'myqueue'
    ;

CREATE MATERIALIZED VIEW IF NOT EXISTS event_view
TO event AS
SELECT
    toDateTime(toUInt64(divide(timestamp, 1000000000))) AS timestamp,
    id AS id,
    body AS body
FROM rabbitmq_entry;

-- ==========================================

DROP DATABASE IF EXISTS dw;
CREATE DATABASE IF NOT EXISTS dw;
USE dw;

-- ======== APP consumer config =============
CREATE TABLE IF NOT EXISTS events (
    `event_id` UInt32,
    `action` String,
    `process` String,
    `order_id` UInt32,
    `restaurant_id` UInt32,
    `order_status` String,
    `timestamp` DateTime
) Engine = Memory;
-- Engine = MergeTree() ORDER BY event_id;

CREATE TABLE IF NOT EXISTS rabbitmq_events
(
    `event_id` UInt32,
    `action` String,
    `process` String,
    `order_id` UInt32,
    `restaurant_id` UInt32,
    `order_status` String,
    `timestamp` DateTime
) ENGINE = RabbitMQ SETTINGS
    rabbitmq_host_port = 'rabbitmq:5672',
    rabbitmq_routing_key_list = 'events.order_event.store',
    rabbitmq_exchange_name = 'orders.exchange',
    rabbitmq_format = 'JSONEachRow',
    rabbitmq_exchange_type = 'topic',
    rabbitmq_num_consumers = 1
    ;
    -- rabbitmq_exchange_name = 'dw-exchange',
    -- rabbitmq_routing_key_list = 'myqueue',

CREATE MATERIALIZED VIEW IF NOT EXISTS events_view
TO events AS
SELECT event_id, action, process, order_id, restaurant_id, order_status, timestamp
FROM rabbitmq_events;