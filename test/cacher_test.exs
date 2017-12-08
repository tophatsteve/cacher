defmodule CacherTest do
  use ExUnit.Case
  doctest Cacher

  test "new cache is empty" do
    {:ok, cache} = Cacher.init(:ok)
    assert cache == %{}
  end

  test "write creates a key if it does not exist" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key", "val"}, cache)
    assert Map.has_key?(cache, "key")
  end

  test "read returns correct value" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key", "val"}, cache)
    {:reply, val, _cache} = Cacher.handle_call({:read, "key"}, nil, cache)
    assert val == "val"
  end  

  test "exists? returns true if the key exists" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key", "val"}, cache)
    {:reply, does_exist, _cache}   = Cacher.handle_call({:exists?, "key"}, nil, cache)
    assert does_exist == true
  end 

  test "exists? returns false if the key does not exist" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key", "val"}, cache)
    {:reply, does_exist, _cache}   = Cacher.handle_call({:exists?, "missing_key"}, nil, cache)
    assert does_exist == false    
  end

  test "delete removes the specified key" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key1", "val1"}, cache)  
    {:noreply, cache} = Cacher.handle_cast({:write, "key2", "val2"}, cache)
    {:noreply, cache} = Cacher.handle_cast({:write, "key3", "val3"}, cache)

    {:noreply, cache} = Cacher.handle_cast({:delete, "key1"}, cache)
    assert Map.has_key?(cache, "key1") == false
  end

  test "delete leaves non-specified keys in cache" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key1", "val1"}, cache)  
    {:noreply, cache} = Cacher.handle_cast({:write, "key2", "val2"}, cache)
    {:noreply, cache} = Cacher.handle_cast({:write, "key3", "val3"}, cache)

    {:noreply, cache} = Cacher.handle_cast({:delete, "key1"}, cache)    
    assert length(Map.keys(cache)) == 2
  end

  test "clear removes all entries in the cache" do
    {:ok, cache} = Cacher.init(:ok)
    {:noreply, cache} = Cacher.handle_cast({:write, "key1", "val1"}, cache)  
    {:noreply, cache} = Cacher.handle_cast({:write, "key2", "val2"}, cache)
    {:noreply, cache} = Cacher.handle_cast({:write, "key3", "val3"}, cache)

    {:noreply, cache} = Cacher.handle_cast(:clear, cache)
    assert length(Map.keys(cache)) == 0
  end
end
