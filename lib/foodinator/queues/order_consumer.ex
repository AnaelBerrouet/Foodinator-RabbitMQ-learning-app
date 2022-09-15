defmodule Foodinator.Queues.OrderConsumer do
  alias Foodinator.Orders
  alias Foodinator.Orders.Order
  alias Foodinator.Queues.Topology

  require Logger

  @general_topic "orders"
  @channel :default

  def wait_for_messages(channel, restaurant_id) do
    receive do
      {:basic_deliver, payload, meta} ->
        Logger.warn(
          "#{__MODULE__} | [x] Restaurant #{restaurant_id} received: [#{meta.routing_key}] - #{payload}"
        )

        try do
          {:ok, %{"order_id" => order_id}} = Jason.decode(payload)

          order_id
          |> Orders.get_order!()
          |> handle_message(meta.routing_key)
        rescue
          error ->
            Logger.error(
              "#{__MODULE__} | Failed to process message for restaurant #{restaurant_id} - message: #{payload} - error: #{inspect(error)}"
            )
        end

        wait_for_messages(channel, restaurant_id)
    end
  end

  def launch_restaurant_order_consumer(restaurant_id) do
    with {:ok, channel} <- AMQP.Application.get_channel(@channel) do
      {:ok, %{queue: queue_name}} =
        AMQP.Queue.declare(channel, "",
          arguments: [{"x-dead-letter-exchange", Topology.dead_letter_exchange()}],
          durable: true
        )

      binding_key = "#{@general_topic}.#{restaurant_id}.request.*"
      AMQP.Queue.bind(channel, queue_name, Topology.main_exchange(), routing_key: binding_key)

      AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

      Logger.warn(
        "#{__MODULE__} | [*] Restaurant #{restaurant_id} waiting for messages with binding_key `#{binding_key}`..."
      )

      wait_for_messages(channel, restaurant_id)
    end
  end

  def handle_message(%Order{status: "initiated"} = order, "orders.1.request.new") do
    accept_order_request = :rand.uniform(2) == 1

    new_status = if accept_order_request, do: "processing", else: "rejected"

    case Orders.update_order(order, %{status: new_status}) do
      {:ok, order} ->
        # Publish order message for client to consume
        Orders.send_order_confirmation(order)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Order update error: #{changeset}")
    end
  end

  def handle_message(_order, "orders.1.request.new") do
    :ok
  end
end
