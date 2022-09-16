defmodule Foodinator.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foodinator.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        action: "some action",
        process: "some process"
      })
      |> Foodinator.Events.create_event()

    event
  end
end
