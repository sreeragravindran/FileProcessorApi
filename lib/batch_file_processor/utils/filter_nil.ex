defmodule BatchFileProcessor.Utils.FilterNil do
    @moduledoc false
    
    def get_map_without_nil_values(array) when is_list(array) do
      Enum.map(array, fn map -> 
        get_map_without_nil_values(map)
      end)
    end
  
    def get_map_without_nil_values(map) do
      IO.inspect map
      map
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
    end

    def get_map_without_nil_values(any) do
       IO.inspect any
    end
  end    
  