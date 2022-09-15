defmodule Foodinator.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Foodinator.Restaurants.Restaurant

  @statuses ~w( initiated confirmed processing ready rejected canceled)

  schema "orders" do
    field :name, :string
    field :address, :string
    field :item, Ecto.UUID
    field :status, :string
    belongs_to :restaurant, Restaurant

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:name, :address, :item, :status, :restaurant_id])
    |> validate_required([:name, :address, :restaurant_id, :item])
    |> foreign_key_constraint(:restaurant_id)
    |> validate_inclusion(:status, @statuses)
  end
end
