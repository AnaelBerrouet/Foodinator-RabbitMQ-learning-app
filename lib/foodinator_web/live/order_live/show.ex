defmodule FoodinatorWeb.OrderLive.Show do
  use FoodinatorWeb, :live_view

  alias Foodinator.Orders
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # Subscribe parent liveview to PubSub messages for current order
    PubSub.subscribe(Foodinator.PubSub, "order:#{id}")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:order, Orders.get_order!(id))}
  end

  @impl true
  def handle_info(%{topic: "order:" <> order_id, payload: action}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Your order has been #{action}!")
     |> assign(:order, Orders.get_order!(order_id))}
  end

  defp page_title(:show), do: "Show Order"
  defp page_title(:edit), do: "Edit Order"
end
