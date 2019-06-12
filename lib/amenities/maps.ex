defmodule Amenities.Maps do
  @moduledoc """
  Map helpers
  """

  alias Amenities.Funcs
  alias Amenities.Monies

  defdelegate atomify(map), to: Prelude.Map
  defdelegate stringify(map), to: Prelude.Map

  @doc """
  Returns a map with nil values omitted
  """
  @spec compact_if(struct() | map(), boolean()) :: map()
  def compact_if(struct, true), do: compact(struct)
  def compact_if(struct, false), do: struct

  @doc """
  Returns a map with nil values omitted
  """
  @spec compact(struct()) :: map()
  def compact(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> compact()
  end

  @spec compact(map()) :: map()
  def compact(map) when is_map(map) do
    for {k, v} <- map, v != nil, into: %{}, do: {k, v}
  end

  @doc """
  Applies a `fun` to the `field` retrieved from two maps `map` and `acc`.  Merges into the `acc`.
  """
  @spec merge_by(map(), field :: String.t() | atom(), map(), fun()) :: map()
  def merge_by(acc, field, map, fun) when is_map(acc) and is_map(map) and is_function(fun) do
    left = Map.get(map, field)
    right = Map.get(acc, field)

    value =
      case Funcs.arity(fun) do
        1 -> fun.([left, right])
        2 -> fun.(left, right)
      end

    Map.put(acc, field, value)
  end

  @doc """
  Returns a map with nil values omitted
  """
  @spec module_keys(atom()) :: list(atom())
  def module_keys(module) when is_atom(module) do
    module
    |> struct()
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Map.keys()
  end

  def get_list_in(_, []), do: []
  def get_list_in(nil, _), do: []

  def get_list_in(struct, keys) when is_map(struct) and is_list(keys) do
    keys
    |> Enum.reduce(struct, fn
      _key, nil ->
        nil

      key, record when is_map(record) ->
        Map.get(record, key)
    end)
    |> List.wrap()
  end

  def keys_with_value(%{__struct__: _} = struct, val) do
    struct
    |> Map.from_struct()
    |> keys_with_value(val)
  end

  def keys_with_value(map, val) when is_map(map) do
    map
    |> do_keys_with_value(val)
    |> Enum.sort()
  end

  defp do_keys_with_value(map, val) when is_map(map) do
    for {k, v} <- map, v == val, do: k
  end

  def transform_values_money_to_decimal(map) do
    Enum.into(map, %{}, fn
      {key, %Money{} = amount} ->
        {key, amount |> Monies.to_decimal() |> Decimal.reduce()}

      {key, %Decimal{} = decimal} ->
        {key, Decimal.reduce(decimal)}

      {key, value} ->
        {key, value}
    end)
  end
end
