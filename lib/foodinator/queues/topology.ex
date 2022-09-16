defmodule Foodinator.Queues.Topology do
  @moduledoc """
  Task module to setup RabbitMQ Topology on startup.
  """
  use Task

  alias Foodinator.Restaurants
  alias Foodinator.Queues.OrderConsumer
  alias Foodinator.Queues.ClientConsumer

  require Logger

  @channel :default

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  @doc """
  Declare RabbitMQ Topology
  """
  @spec run :: :ok
  def run do
    Logger.debug("#{__MODULE__} | Initalizing...")
    {:ok, chan} = AMQP.Application.get_channel(@channel)
    :ok = AMQP.Exchange.declare(chan, main_exchange(), :topic, durable: true)
    :ok = AMQP.Exchange.declare(chan, dead_letter_exchange(), :topic, durable: true)
    :ok = AMQP.Exchange.declare(chan, retry_exchange(), :topic, durable: true)

    # Instantiate the Restaurant Order Consumers
    for restaurant <- Restaurants.list_restaurants() do
      Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
        OrderConsumer.launch_restaurant_order_consumer(restaurant.id)
      end)
    end

    Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
      ClientConsumer.launch_client_order_consumer()
    end)

    :ok
  end

  ################################################
  # Utility functions for this and other modules #
  ################################################
  def main_exchange, do: "orders.exchange"
  def dead_letter_exchange, do: "orders.exchange.dlx"
  def retry_exchange, do: "orders.exchange.retry"

  def channel, do: @channel
end
