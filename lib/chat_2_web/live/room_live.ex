defmodule Chat2Web.RoomLive do
  use Chat2Web, :live_view
  require Logger

  # Connecting to the current room
  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)
    if connected?(socket), do: Chat2Web.Endpoint.subscribe(topic)

    {:ok, assign(socket,
      room_id: room_id,
      topic: topic,
      username: username,
      message: "",
      messages: [%{uuid: UUID.uuid4(), content: "#{username} joined the chat", username: "system"}],
      temporary_assigns: [messages: []])
    }
  end

  # Handling of form submit action
  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
    Chat2Web.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  #  Clearing up the form
  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  # Handler for adding new message to list assingned to current socket
  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end
end
