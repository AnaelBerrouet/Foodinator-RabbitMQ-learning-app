defmodule Foodinator.EventsTest do
  use Foodinator.DataCase

  alias Foodinator.Events

  describe "events" do
    alias Foodinator.Events.Event

    import Foodinator.EventsFixtures

    @invalid_attrs %{action: nil, process: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{action: "some action", process: "some process"}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.action == "some action"
      assert event.process == "some process"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{action: "some updated action", process: "some updated process"}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.action == "some updated action"
      assert event.process == "some updated process"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
