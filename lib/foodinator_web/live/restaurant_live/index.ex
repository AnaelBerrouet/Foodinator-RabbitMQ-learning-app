defmodule FoodinatorWeb.RestaurantLive.Index do
  use FoodinatorWeb, :live_view

  alias Foodinator.Restaurants
  alias Foodinator.Restaurants.Restaurant

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :restaurants, list_restaurants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Restaurant")
    |> assign(:restaurant, Restaurants.get_restaurant!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Restaurant")
    |> assign(:restaurant, %Restaurant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Restaurants")
    |> assign(:restaurant, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    restaurant = Restaurants.get_restaurant!(id)
    {:ok, _} = Restaurants.delete_restaurant(restaurant)

    {:noreply, assign(socket, :restaurants, list_restaurants())}
  end

  defp list_restaurants do
    Restaurants.list_restaurants()
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
end
