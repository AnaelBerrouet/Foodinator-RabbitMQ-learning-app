defmodule Foodinator.Restaurants.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Foodinator.Orders.Order

  schema "restaurants" do
    field :name, :string
    field :logo, :string
    field :items, :map

    has_many :orders, Order, on_delete: :nothing

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :logo, :items])
    |> validate_required([:name])
  end
end
