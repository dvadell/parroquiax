defmodule Parroquiax.Repo.Migrations.CreateQrEntries do
  use Ecto.Migration

  def change do
    create table(:qr_entries) do
      add :qr, :string, null: false
      add :location, :string, null: false
      add :date, :date, null: false

      timestamps()
    end
  end
end
