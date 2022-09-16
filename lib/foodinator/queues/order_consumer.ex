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
          Logger.debug("Decoding JSON payload...")
          {:ok, %{"order_id" => order_id}} = Jason.decode(payload)

          action = extract_action_from_key(meta.routing_key)

          Logger.debug("Fetching message and calling handle_message...")

          order_id
          |> Orders.get_order!()
          |> handle_message(action)
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

  defp extract_action_from_key(routing_key) do
    routing_key
    |> String.split(".")
    |> List.last()
  end

  def handle_message(%Order{status: "initiated"} = order, "new") do
    accept_order_request = :rand.uniform(2) == 1

    new_status = if accept_order_request, do: "processing", else: "rejected"

    case Orders.update_order(order, %{status: new_status}) do
      {:ok, order} ->
        # Publish order message for client to consume
        if order.status == "processing" do
          Orders.send_order_confirmation(order)
        else
          Orders.send_order_rejection(order)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Order update error: #{changeset}")
    end
  end

  def handle_message(order, "cancel") do
    case Orders.update_order(order, %{status: "canceled"}) do
      {:ok, order} ->
        # Publish order message for client to consume
        Orders.send_cancelation_acknowledgement(order)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Order update error: #{changeset}")
    end
  end

  def handle_message(order, routing_key),
    do:
      Logger.error(
        "#{__MODULE__} | Unknown message and order status found. Order: #{inspect(order)}, Routing Key: #{routing_key}"
      )
end
