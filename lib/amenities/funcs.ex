defmodule Amenities.Funcs do
  @moduledoc """
  Function Helpers
  """

  @doc """
  Returns the arity of a fucntion

  ## Examples

      iex> Amenities.Funcs.arity(fn -> nil end)
      0

      iex> Amenities.Funcs.arity(fn _ -> nil end)
      1

      iex> Amenities.Funcs.arity(fn _, _ -> nil end)
      2

  """
  @spec arity(fun()) :: integer()
  def arity(func) when is_function(func) do
    :erlang.fun_info(func)[:arity]
  end
end
