defmodule Foodinator.Queues.EventConsumer do
  alias Foodinator.Events
  alias Foodinator.Queues.Topology

  require Logger

  @general_topic "orders"
  @channel :default

  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        Logger.warn("#{__MODULE__} | [x] Received: [#{meta.routing_key}] - #{payload}")

        try do
          {:ok, %{"order_id" => order_id}} = Jason.decode(payload)
          handle_message(order_id, meta.routing_key)
        rescue
          error ->
            Logger.error(
              "#{__MODULE__} | Failed to process message - message: #{payload} - error: #{inspect(error)}"
            )
        end

        wait_for_messages(channel)
    end
  end

  def launch_event_consumer() do
    with {:ok, channel} <- AMQP.Application.get_channel(@channel) do
      {:ok, %{queue: queue_name}} =
        AMQP.Queue.declare(channel, "",
          arguments: [{"x-dead-letter-exchange", Topology.dead_letter_exchange()}],
          durable: true
        )

      binding_key = "#{@general_topic}.#"
      AMQP.Queue.bind(channel, queue_name, Topology.main_exchange(), routing_key: binding_key)

      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

      Logger.warn("#{__MODULE__} | [*] Waiting for messages with binding_key `#{binding_key}`...")

      wait_for_messages(channel)
    end
  end

  def handle_message(order_id, "orders.update." <> _ = routing_key) do
    case Events.create_event(%{order_id: order_id, action: routing_key, process: "Restaurant"}) do
      {:ok, _event} ->
        FoodinatorWeb.Endpoint.broadcast("events", "update", nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Event update error: #{changeset}")
    end

    :ok
  end

  def handle_message(order_id, "orders." <> _ = routing_key) do
    case Events.create_event(%{order_id: order_id, action: routing_key, process: "Client"}) do
      {:ok, _event} ->
        FoodinatorWeb.Endpoint.broadcast("events", "update", nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Event update error: #{changeset}")
    end

    :ok
  end
end
