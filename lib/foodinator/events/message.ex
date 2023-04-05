defmodule Foodinator.Events.Message do
  alias Foodinator.Events.Event
  alias Foodinator.Orders.Order

  require Logger

  @general_topic "events"

  @derive {Jason.Encoder,
           only: [
             :event_id,
             :action,
             :process,
             :order_id,
             :restaurant_id,
             :order_status,
             :timestamp
           ]}
  defstruct [
    :event_id,
    :action,
    :process,
    :order_id,
    :restaurant_id,
    :order_status,
    :topic,
    :timestamp
  ]

  def store_order_event(%Event{order: %Order{}} = event) do
    new(event, :store_order_event)
  end

  defp new(event, :store_order_event) do
    %__MODULE__{
      event_id: event.id,
      action: event.action,
      process: event.process,
      order_id: event.order_id,
      restaurant_id: event.order.restaurant_id,
      order_status: event.order.status,
      timestamp: event.inserted_at,
      topic: "#{@general_topic}.order_event.store"
    }
  end
end
