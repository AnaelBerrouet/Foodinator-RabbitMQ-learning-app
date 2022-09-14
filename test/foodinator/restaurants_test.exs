defmodule Foodinator.RestaurantsTest do
  use Foodinator.DataCase

  alias Foodinator.Restaurants

  describe "restaurants" do
    alias Foodinator.Restaurants.Restaurant

    import Foodinator.RestaurantsFixtures

    @invalid_attrs %{items: nil, logo: nil, name: nil}

    test "list_restaurants/0 returns all restaurants" do
      restaurant = restaurant_fixture()
      assert Restaurants.list_restaurants() == [restaurant]
    end

    test "get_restaurant!/1 returns the restaurant with given id" do
      restaurant = restaurant_fixture()
      assert Restaurants.get_restaurant!(restaurant.id) == restaurant
    end

    test "create_restaurant/1 with valid data creates a restaurant" do
      valid_attrs = %{items: %{}, logo: "some logo", name: "some name"}

      assert {:ok, %Restaurant{} = restaurant} = Restaurants.create_restaurant(valid_attrs)
      assert restaurant.items == %{}
      assert restaurant.logo == "some logo"
      assert restaurant.name == "some name"
    end

    test "create_restaurant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Restaurants.create_restaurant(@invalid_attrs)
    end

    test "update_restaurant/2 with valid data updates the restaurant" do
      restaurant = restaurant_fixture()
      update_attrs = %{items: %{}, logo: "some updated logo", name: "some updated name"}

      assert {:ok, %Restaurant{} = restaurant} =
               Restaurants.update_restaurant(restaurant, update_attrs)

      assert restaurant.items == %{}
      assert restaurant.logo == "some updated logo"
      assert restaurant.name == "some updated name"
    end

    test "update_restaurant/2 with invalid data returns error changeset" do
      restaurant = restaurant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Restaurants.update_restaurant(restaurant, @invalid_attrs)

      assert restaurant == Restaurants.get_restaurant!(restaurant.id)
    end

    test "delete_restaurant/1 deletes the restaurant" do
      restaurant = restaurant_fixture()
      assert {:ok, %Restaurant{}} = Restaurants.delete_restaurant(restaurant)
      assert_raise Ecto.NoResultsError, fn -> Restaurants.get_restaurant!(restaurant.id) end
    end

    test "change_restaurant/1 returns a restaurant changeset" do
      restaurant = restaurant_fixture()
      assert %Ecto.Changeset{} = Restaurants.change_restaurant(restaurant)
    end
  end
end
