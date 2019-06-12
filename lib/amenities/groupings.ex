defmodule Amenities.Groupings do
  @moduledoc """
  Grouping Utils
  """

  alias Amenities.Maps

  def ungroup({oks, _fails}) do
    Enum.flat_map(oks, fn {_date, items} -> List.wrap(items) end)
  end

  def transpose(list, from: module) when is_list(list) and is_atom(module) do
    module
    |> Maps.module_keys()
    |> Enum.into(%{}, fn key ->
      {key, Enum.map(list, &Map.get(&1, key))}
    end)
  end

  def map_split_ok(grouping, group, fun) when is_list(group) and is_function(fun) do
    {oks, fails} =
      group
      |> Enum.map(fn item ->
        case fun.({grouping, item, group}) do
          {:ok, result} -> {:ok, result}
          _ -> item
        end
      end)
      |> Enum.split_with(fn
        {:ok, _} -> true
        _ -> false
      end)

    {Enum.map(oks, fn {:ok, item} -> item end), fails}
  end

  def each_in_group_ok({oks, fails}, fun)
      when is_list(oks) and is_list(fails) and is_function(fun) do
    Enum.reduce(oks, {[], fails}, fn {date, group}, {oks, fails} ->
      case map_split_ok(date, group, fun) do
        {[], inner_fails} ->
          {oks, fails ++ inner_fails}

        {inner_oks, inner_fails} ->
          {oks ++ [{date, inner_oks}], fails ++ inner_fails}
      end
    end)
  end

  def reduce_in_group({oks, fails}, fun)
      when is_list(oks) and is_list(fails) and is_function(fun) do
    oks =
      Enum.reduce(oks, [], fn {date, group}, acc ->
        acc ++ [{date, Enum.reduce(group, fun)}]
      end)

    {oks, fails}
  end

  def reduce_in_group({oks, fails}, initial, fun)
      when is_list(oks) and is_list(fails) and is_function(fun) do
    oks =
      Enum.reduce(oks, [], fn {date, group}, acc ->
        acc ++ [{date, Enum.reduce(group, initial, fun)}]
      end)

    {oks, fails}
  end

  def group_by_month_year(list, fun) when is_list(list) and is_function(fun) do
    full_grouping =
      list
      |> Enum.group_by(fn item ->
        case fun.(item) do
          %module{month: month, year: year} when module in [Date, DateTime] -> {year, month}
          _ -> :failed_match
        end
      end)

    failed_match = Map.get(full_grouping, :failed_match, [])

    grouping =
      full_grouping
      |> Map.delete(:failed_match)
      |> Enum.sort()
      |> Enum.reverse()

    {grouping, failed_match}
  end

  def apply_to_groups({oks, fails}, fun)
      when is_list(oks) and is_list(fails) and is_function(fun) do
    {fun.(oks), fails}
  end

  def apply_in_group({oks, fails}, fun)
      when is_list(oks) and is_list(fails) and is_function(fun) do
    oks =
      Enum.map(oks, fn {date, group} ->
        {date, fun.(group)}
      end)

    {oks, fails}
  end
end
