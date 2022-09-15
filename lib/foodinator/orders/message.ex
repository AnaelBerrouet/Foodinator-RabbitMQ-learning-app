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

  def new(order, :request) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.#{order.restaurant_id}.request.new"
    }
  end

  def new(order, :cancel) do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.#{order.restaurant_id}.request.cancel"
    }
  end

  def new(order, action) when action in ~w( confirm )a do
    %__MODULE__{
      order_id: order.id,
      topic: "#{@general_topic}.#{order.id}.update"
    }
  end
end
