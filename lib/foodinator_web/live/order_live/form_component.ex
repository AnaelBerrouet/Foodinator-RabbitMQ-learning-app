defmodule FoodinatorWeb.OrderLive.FormComponent do
  use FoodinatorWeb, :live_component

  alias Foodinator.Orders
  # alias Foodinator.Restaurants

  require Logger

  @impl true
  def update(%{order: order} = assigns, socket) do
    changeset = Orders.change_order(order)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:selected_restaurant, nil)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    Logger.debug(
      "#{__MODULE__} | Action: #{inspect(socket.assigns.action)} - ORDER PARAMS: #{inspect(order_params)}"
    )

    changeset =
      socket.assigns.order
      |> Orders.change_order(order_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> maybe_update_socket_with_restaurant_selection(socket.assigns.action, order_params)
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    save_order(socket, socket.assigns.action, order_params)
  end

  def restaurants_select(restaurants) do
    Enum.map(restaurants, fn restaurant ->
      {restaurant.name, restaurant.id}
    end)
  end

  def restaurant_item_select(restaurant) do
    Enum.map(restaurant.items, fn {k, v} ->
      {v, k}
    end)
  end

  defp maybe_update_socket_with_restaurant_selection(socket, :new, %{
         "restaurant_id" => restaurant_id
       }) do
    selected_restaurant =
      Enum.find(socket.assigns.restaurants, fn restaurant ->
        Integer.to_string(restaurant.id) == restaurant_id
      end)

    Logger.debug("#{__MODULE__} | Selected Restaurant: #{inspect(selected_restaurant)}")
    assign(socket, :selected_restaurant, selected_restaurant)
  end

  defp maybe_update_socket_with_restaurant_selection(socket, _action, _order_params) do
    socket
  end

  defp save_order(socket, :edit, order_params) do
    case Orders.update_order(socket.assigns.order, order_params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_order(socket, :new, order_params) do
    case Orders.create_order(order_params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
