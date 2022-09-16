defmodule FoodinatorWeb.OrderLive.Index do
  use FoodinatorWeb, :live_view

  alias Foodinator.Orders
  alias Foodinator.Orders.Order
  alias Foodinator.Restaurants
  alias Phoenix.PubSub

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    orders = list_orders()
    # Subscribe to PubSub messages for all orders on page
    Enum.each(orders, fn order ->
      PubSub.subscribe(Foodinator.PubSub, "order:#{order.id}")
    end)

    {:ok, assign(socket, :orders, orders)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    Logger.debug("#{__MODULE__} | Action: :edit")

    socket
    |> assign(:page_title, "Edit Order")
    |> assign(:order, Orders.get_order!(id))
    |> assign(:restaurants, nil)
  end

  defp apply_action(socket, :new, _params) do
    Logger.debug("#{__MODULE__} | Action: :new")

    socket
    |> assign(:page_title, "New Order")
    |> assign(:order, %Order{})
    |> assign(:restaurants, Restaurants.list_restaurants())
  end

  defp apply_action(socket, :index, _params) do
    Logger.debug("#{__MODULE__} | Action: :index")

    socket
    |> assign(:page_title, "Listing Orders")
    |> assign(:order, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Orders.get_order!(id)
    {:ok, _} = Orders.delete_order(order)

    {:noreply, assign(socket, :orders, list_orders())}
  end

  @impl true
  def handle_info(%{topic: "order:" <> order_id, payload: action}, socket) do
    Logger.debug(
      "#{__MODULE__} | Received PubSub message for topic: `order:#{order_id}` with payload: #{action}"
    )

    {:noreply,
     socket
     |> put_flash(:info, "Your order has been #{action}!")
     |> assign(:orders, list_orders())}
  end

  defp list_orders do
    Orders.list_orders()
  end

  defp status_pill(status), do: "pill-#{status}"
end
