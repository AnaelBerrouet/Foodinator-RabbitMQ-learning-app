defmodule FoodinatorWeb.RestaurantLive.Show do
  use FoodinatorWeb, :live_view

  alias Foodinator.Restaurants

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:restaurant, Restaurants.get_restaurant!(id))}
  end

  def format_restaurant_items(nil), do: "N/A"
  def format_restaurant_items(items) when is_map(items) do
    Logger.debug("#{__MODULE__} | #{inspect items}")
    if Enum.count(items) <= 0 do
      "N/A"
    else
      Enum.reduce(items, "", fn {_k,v}, acc ->
        acc <> v <> ","
      end)
    end
  end

  defp page_title(:show), do: "Show Restaurant"
  defp page_title(:edit), do: "Edit Restaurant"
end
