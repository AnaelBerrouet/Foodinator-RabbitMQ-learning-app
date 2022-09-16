defmodule Foodinator.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Foodinator.Orders.Order

  schema "events" do
    field :action, :string
    field :process, :string
    belongs_to :order, Order

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:process, :action, :order_id])
    |> validate_required([:process, :action])
  end
end
