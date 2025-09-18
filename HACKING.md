# How to test
```
mix format
mix credo
mix dialyzer
mix sobelow --config
MIX_ENV=test mix test
```

# QR Entry Feature

This feature introduces an API endpoint `/api/qr` to create QR entries.

## Main Files:

*   **`lib/parroquiax/qr_entry.ex`**: Defines the Ecto schema for the `qr_entries` database table. This module handles the structure and validation of QR entry data.
*   **`lib/parroquiax_web/controllers/qr_controller.ex`**: This Phoenix controller manages the API logic for creating QR entries. It handles incoming `POST` requests to `/api/qr`, parses the request body, validates the data, and interacts with the database to save new entries.
*   **`priv/repo/migrations/*_create_qr_entries.exs`**: This database migration file is responsible for creating the initial `qr_entries` table in the PostgreSQL database.
*   **`priv/repo/migrations/*_change_date_to_datetime_in_qr_entries.exs`**: This migration modifies the `qr_entries` table, specifically changing the `date` column from a `date` type to a `utc_datetime` type to store precise timestamps.
*   **`lib/parroquiax_web/router.ex`**: This file defines the application's routes. The `/api/qr` endpoint is configured here to direct incoming requests to the `QrController`.
*   **`test/parroquiax_web/controllers/qr_controller_test.exs`**: Contains unit tests for the `QrController`. These tests ensure that the API endpoint behaves as expected, covering successful creation, validation errors, and correct data handling.