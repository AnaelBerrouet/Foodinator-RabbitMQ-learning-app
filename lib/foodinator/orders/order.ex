defmodule Foodinator.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :address, :string
    field :item, :integer
    field :name, :string
    field :status, :string
    field :restaurant, :id

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:name, :address, :item, :status])
    |> validate_required([:name, :address, :item, :status])
  end
end
