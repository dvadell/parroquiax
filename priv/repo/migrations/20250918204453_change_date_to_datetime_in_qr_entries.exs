defmodule Parroquiax.Repo.Migrations.ChangeDateToDatetimeInQrEntries do
  use Ecto.Migration

  def change do
    alter table(:qr_entries) do
      modify :date, :utc_datetime, from: :date
    end
  end
end
