defmodule Cacher do
  use GenServer

  @name CS

  # Public Api
  def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, :ok, opts ++ [name: CS])
  end

  def write(key, val) do
    GenServer.cast(@name, {:write, key, val})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def exist?(key) do
    GenServer.call(@name, {:exists?, key})
  end

  # GenServer implementation
  def init(:ok) do
      {:ok, %{}} # initial state is an empty map
  end

  def handle_call({:read, key}, _from, state) do
    {:reply, state[key], state}
  end  

  def handle_call({:exists?, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end  

  def handle_cast({:write, key, val}, state) do
      {:noreply, Map.put(state, key, val)}
  end

  def handle_cast({:delete, key}, state) do
      {:noreply, Map.delete(state, key)}
  end

  def handle_cast(:clear, _state) do
      {:noreply, %{}}
  end

end
