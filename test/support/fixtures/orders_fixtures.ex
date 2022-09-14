defmodule Foodinator.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foodinator.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        address: "some address",
        item: 42,
        name: "some name",
        status: "some status"
      })
      |> Foodinator.Orders.create_order()

    order
  end
end
