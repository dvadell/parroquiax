defmodule Parroquiax.Repo.Migrations.ChangeCurrentEpochToAutoIncrement do
  use Ecto.Migration

  def up do
    # Create a sequence for the current_epoch column
    execute "CREATE SEQUENCE locations_current_epoch_seq"

    # Modify the column to use the sequence as default
    alter table(:locations) do
      modify :current_epoch, :bigint, default: fragment("nextval('locations_current_epoch_seq')")
    end

    # Set the sequence to start from the current maximum value + 1
    execute """
    SELECT setval('locations_current_epoch_seq', 
                  COALESCE((SELECT MAX(current_epoch) FROM locations), 0) + 1, 
                  false)
    """

    # Make the column own the sequence (so it gets dropped if column is dropped)
    execute "ALTER SEQUENCE locations_current_epoch_seq OWNED BY locations.current_epoch"
  end

  def down do
    alter table(:locations) do
      modify :current_epoch, :bigint, default: nil
    end

    execute "DROP SEQUENCE IF EXISTS locations_current_epoch_seq"
  end
end
