defmodule Foodinator.OrdersTest do
  use Foodinator.DataCase

  alias Foodinator.Orders

  describe "orders" do
    alias Foodinator.Orders.Order

    import Foodinator.OrdersFixtures

    @invalid_attrs %{address: nil, item: nil, name: nil, status: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{address: "some address", item: 42, name: "some name", status: "some status"}

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.address == "some address"
      assert order.item == 42
      assert order.name == "some name"
      assert order.status == "some status"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()

      update_attrs = %{
        address: "some updated address",
        item: 43,
        name: "some updated name",
        status: "some updated status"
      }

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.address == "some updated address"
      assert order.item == 43
      assert order.name == "some updated name"
      assert order.status == "some updated status"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
