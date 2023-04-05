defmodule Foodinator.Queues.Publisher do
  alias Foodinator.Queues.Topology

  require Logger

  @publish_opts [
    mandatory: true
    # persistent: true
  ]

  def publish_message(message, topic) when is_struct(message) and is_binary(topic) do
    with {:ok, channel} <- AMQP.Application.get_channel(Topology.channel()),
         {:ok, message} <- transform_message(message),
         :ok <-
           AMQP.Basic.publish(
             channel,
             Topology.main_exchange(),
             topic,
             message,
             @publish_opts
           ) do
      Logger.info("#{__MODULE__} | published message: #{inspect(message)} on topic: #{topic}")
      :ok
    else
      error ->
        Logger.error("#{__MODULE__} | failed to publish message: #{inspect(error)}")
        raise "Error publishing message, #{inspect(error)}"
    end
  end

  defp transform_message(message) do
    Jason.encode(message)
  end
end
