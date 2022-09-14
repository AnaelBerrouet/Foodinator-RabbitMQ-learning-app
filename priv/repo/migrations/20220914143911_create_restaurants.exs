defmodule Foodinator.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :name, :string
      add :logo, :string
      add :items, :map

      timestamps()
    end
  end
end
