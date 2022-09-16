defmodule Foodinator.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Foodinator.Restaurants.Restaurant
  alias Foodinator.Events.Event

  @statuses ~w( initiated processing ready rejected canceled)

  schema "orders" do
    field :name, :string
    field :address, :string
    field :item, Ecto.UUID
    field :status, :string
    belongs_to :restaurant, Restaurant
    has_many :events, Event, on_delete: :nothing

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:name, :address, :item, :status, :restaurant_id])
    |> validate_required([:name, :address, :restaurant_id, :item])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:restaurant_id)
  end
end
