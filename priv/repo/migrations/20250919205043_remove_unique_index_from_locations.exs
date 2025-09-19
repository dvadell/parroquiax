defmodule Parroquiax.Repo.Migrations.RemoveUniqueIndexFromLocations do
  use Ecto.Migration

  def change do
    drop unique_index(:locations, [:location])
  end
end
