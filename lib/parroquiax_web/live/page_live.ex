defmodule ParroquiaxWeb.PageLive do
  use ParroquiaxWeb, :live_view

  alias Parroquiax.QrEntry
  alias Parroquiax.Repo
  alias Phoenix.PubSub

  @topic Parroquiax.PubSub

  def mount(_params, _session, socket) do
    qr_entries = Repo.all(QrEntry)
    {:ok, assign(socket, :qr_entries, qr_entries)}
  end

  def handle_params(_params, _url, socket) do
    PubSub.subscribe(@topic, "new_qr_entry")
    {:noreply, socket}
  end

  def handle_info(qr_entry, socket) do
    {:noreply, update(socket, :qr_entries, fn qr_entries -> [qr_entry | qr_entries] end)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-bold mb-4">QR Entries</h1>
      <ul id="qr-entries" class="list-disc pl-5">
        <%= for qr_entry <- @qr_entries do %>
          <li class="mb-2 p-2 border rounded-lg shadow-sm">
            <p><strong>QR:</strong> {qr_entry.qr}</p>
            <p><strong>Location:</strong> {qr_entry.location}</p>
            <p><strong>Date:</strong> {qr_entry.date}</p>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
