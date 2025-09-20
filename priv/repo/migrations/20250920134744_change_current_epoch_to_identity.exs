defmodule Parroquiax.Repo.Migrations.ChangeCurrentEpochToIdentity do
  use Ecto.Migration

  def up do
    # Drop the existing sequence default and sequence if they exist
    execute "ALTER TABLE locations ALTER COLUMN current_epoch DROP DEFAULT"
    execute "DROP SEQUENCE IF EXISTS locations_current_epoch_seq"
    
    # Drop the existing current_epoch column
    execute "ALTER TABLE locations DROP COLUMN current_epoch"
    
    # Add it back as an identity column using raw SQL
    execute "ALTER TABLE locations ADD COLUMN current_epoch bigint GENERATED ALWAYS AS IDENTITY"
  end

  def down do
    # Remove the identity column
    alter table(:locations) do
      remove :current_epoch
    end
    
    # Add back the regular column with sequence
    execute "CREATE SEQUENCE locations_current_epoch_seq"
    
    alter table(:locations) do
      add :current_epoch, :bigint, default: fragment("nextval('locations_current_epoch_seq')")
    end
    
    execute "ALTER SEQUENCE locations_current_epoch_seq OWNED BY locations.current_epoch"
  end
end
