defmodule Foodinator.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :name, :string
      add :address, :string
      add :item, :uuid
      add :status, :string
      add :restaurant_id, references(:restaurants, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:restaurant_id])
  end
end
