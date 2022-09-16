defmodule FoodinatorWeb.RestaurantLive.FormComponent do
  use FoodinatorWeb, :live_component

  alias Foodinator.Restaurants
  alias Foodinator.Queues.OrderConsumer

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

  def handle_event("save", %{"restaurant" => params}, socket) do
    Logger.debug("Restaurant Params: #{inspect(params)}")
    params = Map.put(params, "items", Jason.decode!(params["items"]))
    save_restaurant(socket, socket.assigns.action, params)
  end

  def handle_event("validate-item", params, socket) do
    Logger.debug("Validating item: #{inspect(params)}")
    {:noreply, socket}
  end

  def handle_event(
        "add-item",
        %{"new_item" => %{"value" => item}},
        %{assigns: %{restaurant: restaurant, changeset: changeset}} = socket
      ) do
    changeset_items = Map.get(changeset.changes, :items, %{})
    current_items = Map.merge(restaurant.items, changeset_items)
    items_new = Map.put(current_items, UUID.uuid4(), item)

    new_changeset = Ecto.Changeset.put_change(changeset, :items, items_new)

    Logger.debug("New Changeset: #{inspect(new_changeset)}")
    {:noreply, assign(socket, :changeset, new_changeset)}
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
    Logger.warn("Creating restaurant...")

    case Restaurants.create_restaurant(restaurant_params) do
      {:ok, restaurant} ->
        # Launch the new restaurant's order consumer process supervised by the `Task.Supervisor`
        Task.Supervisor.async_nolink(Foodinator.TaskSupervisor, fn ->
          OrderConsumer.launch_restaurant_order_consumer(restaurant.id, restaurant.name)
        end)

        {:noreply,
         socket
         |> put_flash(:info, "Restaurant created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def format_restaurant_items(nil), do: "N/A"

  def format_restaurant_items(items) when is_map(items) do
    Logger.debug("#{__MODULE__} | #{inspect(items)}")

    if Enum.count(items) <= 0 do
      "N/A"
    else
      Enum.reduce(items, "", fn {_k, v}, acc ->
        acc <> v <> ","
      end)
    end
  end
end
