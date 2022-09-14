defmodule Foodinator.RestaurantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foodinator.Restaurants` context.
  """

  @doc """
  Generate a restaurant.
  """
  def restaurant_fixture(attrs \\ %{}) do
    {:ok, restaurant} =
      attrs
      |> Enum.into(%{
        items: %{},
        logo: "some logo",
        name: "some name"
      })
      |> Foodinator.Restaurants.create_restaurant()

    restaurant
  end
end
