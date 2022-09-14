defmodule Foodinator.Restaurants.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "restaurants" do
    field :items, :map
    field :logo, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :logo, :items])
    |> validate_required([:name])
  end
end
