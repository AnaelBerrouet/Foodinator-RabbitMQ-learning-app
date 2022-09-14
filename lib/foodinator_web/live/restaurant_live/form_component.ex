defmodule FoodinatorWeb.RestaurantLive.FormComponent do
  use FoodinatorWeb, :live_component

  alias Foodinator.Restaurants

  require Logger

  @impl true
  def update(%{restaurant: restaurant} = assigns, socket) do
    changeset = Restaurants.change_restaurant(restaurant)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"restaurant" => restaurant_params}, socket) do
    changeset =
      socket.assigns.restaurant
      |> Restaurants.change_restaurant(restaurant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"restaurant" => restaurant_params}, socket) do
    save_restaurant(socket, socket.assigns.action, restaurant_params)
  end

  def handle_event("validate-item", params, socket) do
    Logger.debug("Validating item: #{inspect params}")
    {:noreply, socket}
  end

  def handle_event("add-item", %{"new_item" => %{"value" => item}}, %{assigns: %{restaurant: restaurant}} = socket) do

    items_new = Map.put_new(restaurant.items, UUID.uuid4(), item)
    Logger.debug("Items New: #{inspect items_new}")

    save_restaurant(socket, socket.assigns.action, %{items: items_new})
  end

  defp save_restaurant(socket, :edit, restaurant_params) do
    case Restaurants.update_restaurant(socket.assigns.restaurant, restaurant_params) do
      {:ok, _restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurant updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_restaurant(socket, :new, restaurant_params) do
    case Restaurants.create_restaurant(restaurant_params) do
      {:ok, _restaurant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Restaurant created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
