defmodule Foodinator.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :name, :string
      add :address, :string
      add :item, :integer
      add :status, :string
      add :restaurant, references(:restaurants, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:restaurant])
  end
end
