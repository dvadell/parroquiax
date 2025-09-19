defmodule Parroquiax.Repo.Migrations.AddEpochToQrEntries do
  use Ecto.Migration

  def change do
    alter table(:qr_entries) do
      add :epoch, :integer, default: 0
    end
  end
end
