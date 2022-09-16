defmodule Foodinator.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :process, :string
      add :action, :string
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end

    create index(:events, [:order_id])
  end
end
