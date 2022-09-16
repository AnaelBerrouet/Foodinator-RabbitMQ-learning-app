defmodule FoodinatorWeb.EventLive.Index do
  use FoodinatorWeb, :live_view

  alias Foodinator.Events
  alias Phoenix.PubSub

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to PubSub messages for all events
    PubSub.subscribe(Foodinator.PubSub, "events")
    {:ok, assign(socket, :events, list_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, assign(socket, :events, list_events())}
  end

  @impl true
  def handle_info(%{topic: "events", event: "update"}, socket) do
    Logger.warn(
      "#{__MODULE__} | Received PubSub message for topic: `events` for an `update` event."
    )

    {:noreply,
     socket
     |> put_flash(:info, "Events updated")
     |> assign(:events, list_events())}
  end

  defp list_events do
    Events.list_events()
  end
end
