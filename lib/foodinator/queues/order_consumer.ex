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

  def launch_restaurant_order_consumer(restaurant_id, restaurant_name) do
    Logger.info("#{__MODULE__} | Launching #{restaurant_name}...")

    try do
      channel = setup_queue(restaurant_id, restaurant_name)
      wait_for_messages(channel, restaurant_id)
    rescue
      error ->
        Logger.error(
          "#{__MODULE__} | Launch failed for restaurant ##{restaurant_id} (#{restaurant_name}) - error: #{inspect(error)}"
        )
    end
  end

  def setup_queue(restaurant_id, restaurant_name) do
    with {:ok, channel} <- AMQP.Application.get_channel(@channel) do
      {:ok, %{queue: queue_name}} =
        AMQP.Queue.declare(channel, "",
          arguments: [{"x-dead-letter-exchange", Topology.dead_letter_exchange()}],
          durable: true
        )

      binding_key = "#{@general_topic}.#{restaurant_id}.request.*"

      :ok =
        AMQP.Queue.bind(channel, queue_name, Topology.main_exchange(), routing_key: binding_key)

      {:ok, _} = AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

      Logger.warn(
        "#{__MODULE__} | [*] Restaurant ##{restaurant_id} (#{restaurant_name}) waiting for messages with binding_key `#{binding_key}`..."
      )

      channel
    else
      error -> Logger.error("#{error}")
    end
  end

  defp extract_action_from_key(routing_key) do
    routing_key
    |> String.split(".")
    |> List.last()
  end

  defp handle_message(%Order{status: "initiated"} = order, "new") do
    Process.sleep(4000)

    reject_order_request = :rand.uniform(5) == 1
    new_status = if reject_order_request, do: "rejected", else: "processing"

    case Orders.update_order(order, %{status: new_status}) do
      {:ok, order} ->
        # Publish order message for client to consume
        if order.status == "processing" do
          Orders.send_order_confirmation(order)
          # Prepare food
          Logger.debug("#{__MODULE__} | Restaurant now processing order: #{order.id}")

          Task.async(fn ->
            process_order(order)
          end)
        else
          Orders.send_order_rejection(order)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Order update error: #{changeset}")
    end
  end

  defp handle_message(order, "cancel") do
    Process.sleep(4000)

    case Orders.update_order(order, %{status: "canceled"}) do
      {:ok, order} ->
        # Publish order message for client to consume
        Orders.send_cancelation_acknowledgement(order)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Order update error: #{changeset}")
    end
  end

  defp handle_message(order, routing_key),
    do:
      Logger.error(
        "#{__MODULE__} | Unknown message and order status found. Order: #{inspect(order)}, Routing Key: #{routing_key}"
      )

  defp process_order(%Order{status: "processing"} = order) do
    {timeout, _} = Float.to_string(:rand.uniform() * 1000 * 30) |> Integer.parse()
    Process.sleep(timeout)

    case Orders.update_order(order, %{status: "ready"}) do
      {:ok, order} ->
        # Publish order message for client to consume
        Orders.send_order_ready(order)

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{__MODULE__} | Order update error: #{changeset}")
    end

    :ok
  end

  defp process_order(_), do: :ok
end
