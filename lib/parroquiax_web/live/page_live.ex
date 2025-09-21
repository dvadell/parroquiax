defmodule ParroquiaxWeb.PageLive do
  use ParroquiaxWeb, :live_view

  import Ecto.Query

  alias Parroquiax.Locations
  alias Parroquiax.QrEntry
  alias Parroquiax.Repo
  alias Phoenix.PubSub

  @topic Parroquiax.PubSub

  def mount(_params, _session, socket) do
    current_epoch = Locations.get_current_epoch()

    presentes_raw_entries =
      Repo.all(from qe in QrEntry, where: qe.epoch == ^current_epoch, order_by: [desc: qe.inserted_at])

    presentes_entries =
      presentes_raw_entries
      |> Enum.map(fn entry -> Map.put(entry, :expanded, false) end)

    all_qrs_raw = Repo.all(from qe in QrEntry, select: qe.qr)

    all_qrs =
      all_qrs_raw
      |> Enum.uniq()
      |> MapSet.new()

    current_epoch_qrs_raw = Repo.all(from qe in QrEntry, where: qe.epoch == ^current_epoch, select: qe.qr)

    current_epoch_qrs =
      current_epoch_qrs_raw
      |> Enum.uniq()
      |> MapSet.new()

    ausentes_qrs = MapSet.difference(all_qrs, current_epoch_qrs)

    ausentes_entries =
      Enum.map(Enum.to_list(ausentes_qrs), fn qr -> %{qr: qr, expanded: false} end)

    {:ok,
     assign(socket,
       presentes_entries: presentes_entries,
       ausentes_entries: ausentes_entries
     )}
  end

  def handle_params(_params, _url, socket) do
    PubSub.subscribe(@topic, "new_qr_entry")
    PubSub.subscribe(@topic, "reset")
    {:noreply, socket}
  end

  def handle_info(nil, socket) do
    {:noreply, assign(socket, :qr_entries, [])}
  end

  def handle_info(new_qr_entry, socket) do
    current_epoch = Locations.get_current_epoch()

    # Initialize lists from socket assigns
    presentes_entries = socket.assigns.presentes_entries
    ausentes_entries = socket.assigns.ausentes_entries

    # Prepare the new entry with expanded: false
    new_entry_with_expanded = Map.put(new_qr_entry, :expanded, false)

    if new_qr_entry.epoch == current_epoch do
      # Add to Presentes
      updated_presentes = [new_entry_with_expanded | presentes_entries]

      # Remove from Ausentes if it was there
      updated_ausentes = Enum.reject(ausentes_entries, fn entry -> entry.qr == new_qr_entry.qr end)

      {:noreply,
       assign(socket,
         presentes_entries: updated_presentes,
         ausentes_entries: updated_ausentes
       )}
    else
      # Add to Ausentes
      updated_ausentes = [new_entry_with_expanded | ausentes_entries]

      # Remove from Presentes if it was there (less likely for new entry, but good for consistency)
      updated_presentes = Enum.reject(presentes_entries, fn entry -> entry.qr == new_qr_entry.qr end)

      {:noreply,
       assign(socket,
         presentes_entries: updated_presentes,
         ausentes_entries: updated_ausentes
       )}
    end
  end

  def handle_event("toggle-expand", %{"index" => index_str, "group" => group}, socket) do
    index = String.to_integer(index_str)

    list_atom =
      case group do
        "presentes" -> :presentes_entries
        "ausentes" -> :ausentes_entries
        _group -> raise "Unknown group: #{group}"
      end

    updated_list =
      List.update_at(Map.fetch!(socket.assigns, list_atom), index, fn entry ->
        Map.update!(entry, :expanded, fn expanded -> not expanded end)
      end)

    {:noreply, assign(socket, list_atom, updated_list)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4 bg-white">
      <h1 class="text-3xl font-bold mb-4">Presentes</h1>
      <ul id="presentes-entries" class="list-disc pl-5">
        <%= for {qr_entry, index} <- Enum.with_index(@presentes_entries) do %>
          <li
            class="mb-2 p-2 border rounded-lg shadow-sm cursor-pointer"
            data-testid="qr-entry"
            phx-click="toggle-expand"
            phx-value-index={index}
            phx-value-group="presentes"
          >
            <div class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-8 h-8 mr-2">
                <path
                  fill-rule="evenodd"
                  d="M7.5 6a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1 -9 0Zm-3.75 9a4.5 4.5 0 0 1 9 0v2.25c0 1.15-.172 2.29-.431 3.397a6.75 6.75 0 0 1 -9.138 0A12.002 12.002 0 0 1 3.75 17.25V15Zm16.5 0a4.5 4.5 0 0 0 -9 0v2.25c0 1.15.172 2.29.431 3.397a6.75 6.75 0 0 0 9.138 0A12.002 12.002 0 0 0 20.25 17.25V15Z"
                  clip-rule="evenodd"
                />
              </svg>
              <p><strong>QR:</strong> {qr_entry.qr}</p>
            </div>
            <%= if qr_entry.expanded do %>
              <p><strong>Location:</strong> {qr_entry.location}</p>
              <p><strong>Date:</strong> {qr_entry.date}</p>
            <% end %>
          </li>
        <% end %>
      </ul>

      <h1 class="text-3xl font-bold mb-4 mt-8">Ausentes</h1>
      <ul id="ausentes-entries" class="list-disc pl-5">
        <%= for {qr_entry, index} <- Enum.with_index(@ausentes_entries) do %>
          <li
            class="mb-2 p-2 border rounded-lg shadow-sm cursor-pointer"
            data-testid="qr-entry"
            phx-click="toggle-expand"
            phx-value-index={index}
            phx-value-group="ausentes"
          >
            <div class="flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-8 h-8 mr-2">
                <path
                  fill-rule="evenodd"
                  d="M7.5 6a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1 -9 0Zm-3.75 9a4.5 4.5 0 0 1 9 0v2.25c0 1.15-.172 2.29-.431 3.397a6.75 6.75 0 0 1 -9.138 0A12.002 12.002 0 0 1 3.75 17.25V15Zm16.5 0a4.5 4.5 0 0 0 -9 0v2.25c0 1.15.172 2.29.431 3.397a6.75 6.75 0 0 0 9.138 0A12.002 12.002 0 0 0 20.25 17.25V15Z"
                  clip-rule="evenodd"
                />
              </svg>
              <p><strong>QR:</strong> {qr_entry.qr}</p>
            </div>
            <%= if qr_entry.expanded do %>
              <p><strong>Location:</strong> N/A</p>
              <p><strong>Date:</strong> N/A</p>
            <% end %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
