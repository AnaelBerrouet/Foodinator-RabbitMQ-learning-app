defmodule Foodinator.Queues.ClientConsumer do
  alias Foodinator.Orders
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

          order_id
          |> Orders.get_order!()
          |> handle_message(meta.routing_key)
        rescue
          error ->
            Logger.error(
              "#{__MODULE__} | Failed to process message - message: #{payload} - error: #{inspect(error)}"
            )
        end

        wait_for_messages(channel)
    end
  end

  def launch_client_order_consumer() do
    with {:ok, channel} <- AMQP.Application.get_channel(@channel) do
      {:ok, %{queue: queue_name}} =
        AMQP.Queue.declare(channel, "",
          arguments: [{"x-dead-letter-exchange", Topology.dead_letter_exchange()}],
          durable: true
        )

      binding_key = "#{@general_topic}.update"
      AMQP.Queue.bind(channel, queue_name, Topology.main_exchange(), routing_key: binding_key)

      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

      Logger.warn(
        "#{__MODULE__} | [*] Waiting for order update messages with binding_key `#{binding_key}`..."
      )

      wait_for_messages(channel)
    end
  end

  def handle_message(_order, "orders.update") do
    :ok
  end
end
