defmodule Parroquiax.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :location, :string, null: false
      add :current_epoch, :integer, default: 0

      timestamps()
    end

    create unique_index(:locations, [:location])
  end
end
