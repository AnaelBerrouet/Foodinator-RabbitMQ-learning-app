defmodule Foodinator.Orders.Message do
  alias Foodinator.Orders.Order

  require Logger

  @general_topic "orders"

  @derive {Jason.Encoder, only: [:order_id]}
  defstruct [
    :order_id,
    :topic
  ]

  def request(%Order{status: "initiated"} = order) do
    new(order, :request)
  end

  def cancel(%Order{} = order) do
    new(order, :cancel)
  end

  def confirm(%Order{} = order) do
    new(order, :confirm)
  end

  def reject(%Order{} = order) do
    new(order, :reject)
  end

  def ackowledge_cancelation(%Order{} = order) do
    new(order, :ack_cancel)
  end

  # Client->Restaurant messages
  defp new(order, :request) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.#{order.restaurant_id}.request.new"
    }
  end

  # Restaurant->Client messages
  defp new(order, :cancel) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.#{order.restaurant_id}.request.cancel"
    }
  end

  defp new(order, :confirm) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.update.confirmed"
    }
  end

  defp new(order, :reject) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.update.rejected"
    }
  end

  defp new(order, :ack_cancel) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.update.canceled"
    }
  end
end
