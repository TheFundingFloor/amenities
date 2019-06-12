if Code.ensure_loaded?(Decimal) and Code.ensure_loaded?(Money) do
  defmodule Amenities.Monies do
    @moduledoc """
    Money Helpers
    """

    @doc """
    Converts a `Money` to a `Decimal` type
    """
    @spec to_decimal(Money.t()) :: Decimal.t()
    def to_decimal(%Money{} = money) do
      money
      |> Money.to_string(separator: "", symbol: false)
      |> Decimal.new()
    end

    def to_decimal(%Decimal{} = decimal), do: decimal
    def to_decimal(float) when is_float(float), do: Decimal.from_float(float)
    def to_decimal(binary) when is_binary(binary), do: Decimal.new(binary)
    def to_decimal(integer) when is_integer(integer), do: Decimal.new(integer)
    def to_decimal(decimal), do: Decimal.new(decimal)

    @doc """
    Converts a `Money` to a `Integer` type
    """
    @spec to_integer(Money.t()) :: integer

    def to_integer(money) when is_integer(money), do: money
    def to_integer(money) when is_binary(money), do: money |> String.to_float() |> round()
    def to_integer(%Decimal{} = money), do: Decimal.to_integer(money)

    def to_integer(money) do
      money
      |> Money.to_string(separator: "", symbol: false)
      |> to_integer()
    end

    def safe_to_integer(nil), do: 0
    def safe_to_integer(money), do: to_integer(money)

    @spec safe_to_string(Money.t() | integer | Decimal.t() | nil) :: String.t() | nil
    def safe_to_string(nil), do: nil
    def safe_to_string(amount) when is_binary(amount), do: amount

    def safe_to_string(%Money{} = money) do
      money
      |> Money.to_string(symbol: true)
    end

    def safe_to_string(money) when is_integer(money) do
      money
      |> Decimal.new()
      |> Decimal.div(Decimal.new(100))
      |> Decimal.to_string(:normal)
      |> Money.parse!()
      |> safe_to_string()
    end

    def safe_to_string(money) do
      money
      # |> Decimal.new()
      # |> Decimal.div(Decimal.new(100))
      |> Decimal.to_string(:normal)
      |> Money.parse!()
      |> safe_to_string()
    end

    def cast(nil) do
      Money.new(0)
    end

    def cast(money) when is_integer(money) do
      money
      |> Decimal.new()
      |> Decimal.div(Decimal.new(100))
      |> Decimal.to_string(:normal)
      |> Money.parse!()
    end

    def cast(money) when is_binary(money) do
      money
      |> Decimal.parse()
      |> Decimal.div(Decimal.new(100))
      |> Decimal.to_string(:normal)
      |> Money.parse!()
    end

    def cast(money) do
      money
      |> Decimal.div(Decimal.new(100))
      |> Decimal.to_string(:normal)
      |> Money.parse!()
    end
  end
end
