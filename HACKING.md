# How to test
```
mix format
mix credo
mix dialyzer
mix sobelow --config
MIX_ENV=test mix test
```

# Project Structure

## Database Tables

*   **`qr_entries`**: Stores the QR code entries.
    *   `qr`: The QR code string.
    *   `location`: The location where the QR code was scanned.
    *   `date`: The UTC datetime when the QR code was scanned.
    *   `epoch`: An integer representing the epoch of the entry.
*   **`locations`**: Stores the locations and their current epoch.
    *   `location`: The name of the location.
    *   `current_epoch`: The current epoch for the location.

## Key Files

*   **`lib/parroquiax/qr_entry.ex`**: Defines the Ecto schema for the `qr_entries` database table. This module handles the structure and validation of QR entry data.
*   **`lib/parroquiax/location.ex`**: Defines the Ecto schema for the `locations` database table.
*   **`lib/parroquiax_web/controllers/qr_controller.ex`**: This Phoenix controller manages the API logic for creating QR entries. It handles incoming `POST` requests to `/api/qr`, parses the request body, validates the data, and interacts with the database to save new entries.
*   **`priv/repo/migrations/*_create_qr_entries.exs`**: This database migration file is responsible for creating the initial `qr_entries` table in the PostgreSQL database.
*   **`priv/repo/migrations/*_change_date_to_datetime_in_qr_entries.exs`**: This migration modifies the `qr_entries` table, specifically changing the `date` column from a `date` type to a `utc_datetime` type to store precise timestamps.
*   **`priv/repo/migrations/*_add_epoch_to_qr_entries.exs`**: This migration adds the `epoch` column to the `qr_entries` table.
*   **`priv/repo/migrations/*_create_locations.exs`**: This migration creates the `locations` table.
*   **`lib/parroquiax_web/router.ex`**: This file defines the application's routes. The `/api/qr` endpoint is configured here to direct incoming requests to the `QrController`.
*   **`test/parroquiax_web/controllers/qr_controller_test.exs`**: Contains unit tests for the `QrController`. These tests ensure that the API endpoint behaves as expected, covering successful creation, validation errors, and correct data handling.
