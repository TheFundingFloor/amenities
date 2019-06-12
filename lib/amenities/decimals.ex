if Code.ensure_loaded?(Decimal) do
  defmodule Amenities.Decimals do
    @moduledoc """
    Decimal Utils
    """

    @type strict_numeric :: integer() | float() | Decimal.t()
    @type numeric :: strict_numeric | nil

    @doc """
    Generic to integer function
    """
    # def to_int("0"), do: 0
    # def to_int(0.0), do: 0
    def to_int(nil), do: nil
    def to_int(%Decimal{} = decimal), do: Decimal.to_float(decimal)
    def to_int(float) when is_float(float), do: float
    def to_int(int) when is_integer(int), do: int
    def to_int(int) when is_binary(int), do: String.to_integer(int)

    @doc """
    Cast Decimal
    """
    def cast_decimal(nil),
      do: nil

    def cast_decimal(%Decimal{} = decimal),
      do: decimal |> Decimal.reduce()

    def cast_decimal(float) when is_float(float),
      do: float |> Decimal.from_float() |> Decimal.reduce()

    def cast_decimal(binary) when is_binary(binary),
      do:
        binary
        |> String.replace(",", "")
        |> String.replace("$", "")
        |> String.replace("_", "")
        |> Decimal.new()
        |> Decimal.reduce()

    def cast_decimal(integer) when is_integer(integer),
      do: integer |> Decimal.new() |> Decimal.reduce()

    def cast_decimal(%{sign: sign, coef: coef, exp: exp}),
      do: %Decimal{sign: sign, coef: coef, exp: exp} |> Decimal.reduce()

    def cast_decimal(_item),
      do: :error

    @doc """
    Cast Decimal
    """
    def cast_decimal!(numeric) do
      with {:ok, %Decimal{} = decimal} <- cast_decimal_ok(numeric) do
        decimal
      else
        _ -> raise ArgumentError, message: "invalid argument #{inspect(numeric)}"
      end
    end

    @doc """
    Cast Decimal ok
    """
    def cast_decimal_ok(numeric) do
      with %Decimal{} = decimal <- cast_decimal(numeric) do
        {:ok, decimal}
      else
        _ -> :error
      end
    end

    @doc """
    Compare Decimal
    """
    def decimal_cmp(x, y) do
      Decimal.cmp(cast_decimal(x), cast_decimal(y))
    end

    @doc """
    Dist Decimal
    """
    def decimal_dist(x0, x1) do
      x0
      |> cast_decimal()
      |> Decimal.sub(cast_decimal(x1))
      |> Decimal.abs()
      |> Decimal.reduce()
    end

    @doc """
    Add Decimal
    """
    def decimal_add(x0, x1) do
      x0
      |> cast_decimal()
      |> Decimal.add(cast_decimal(x1))
      |> Decimal.reduce()
    end

    @doc """
    Sub Decimal
    """
    def decimal_sub(x0, x1) do
      x0
      |> cast_decimal()
      |> Decimal.sub(cast_decimal(x1))
      |> Decimal.reduce()
    end

    @doc """
    Sum Decimal
    """
    def decimal_sum(decimals) when is_list(decimals) do
      decimals
      |> Enum.map(&cast_decimal!/1)
      |> Enum.reduce(cast_decimal(0), &Decimal.add/2)
      |> Decimal.reduce()
    end

    @doc """
    Avg Decimal
    """
    def decimal_avg(decimals) when is_list(decimals) do
      decimals
      |> decimal_sum()
      |> decimal_div(length(decimals))

      # |> Decimal.reduce()
    end

    @doc """
    Div Decimal
    """
    def decimal_div(dividend, divisor) do
      if Decimal.cmp(cast_decimal!(dividend), 0) == :eq do
        cast_decimal(0)
      else
        dividend
        |> cast_decimal!()
        |> Decimal.div(cast_decimal!(divisor))
        |> Decimal.reduce()
      end
    end

    @doc """
    Percent Decimal
    """
    def as_percentage(amount) do
      amount
      |> decimal_mult(100)
    end

    @doc """
    Percent Decimal
    """
    def from_percentage(amount) do
      amount
      |> decimal_div(100)
    end

    @doc """
    Percent Decimal
    """
    def decimal_percent(allocation, total) do
      allocation
      |> decimal_mult(100)
      |> decimal_div(total)
    end

    @doc """
    Multiply Decimal
    """
    def decimal_mult(left, right) do
      left
      |> cast_decimal!()
      |> Decimal.mult(cast_decimal!(right))
      |> Decimal.reduce()
    end

    @doc """
    Calculate variance
    """
    def variance([]), do: cast_decimal(0)
    def variance([_]), do: cast_decimal(0)

    def variance(list) when is_list(list) do
      list
      |> Enum.map(&to_int/1)
      |> Numerix.Statistics.variance()
      |> cast_decimal()
    end

    @doc """
    Variance percent relative to the mean
    """
    def variance_percent([]), do: cast_decimal(0)
    def variance_percent([_]), do: cast_decimal(100)

    def variance_percent(list) when is_list(list) do
      mean = decimal_avg(list)

      list
      |> Enum.map(&cast_decimal!/1)
      |> Enum.map(fn item ->
        if Decimal.cmp(item, 0) == :eq do
          Decimal.new(0)
        else
          item
          |> decimal_sub(mean)
          |> Decimal.abs()
          |> decimal_div(item)
        end
      end)
      |> decimal_avg()
      |> as_percentage()
      |> decimal_add(100)
    end

    def is_decimal_uniform([]), do: true
    def is_decimal_uniform([_]), do: true

    def is_decimal_uniform(list) when is_list(list) do
      count =
        list
        |> Enum.map(&cast_decimal!/1)
        |> MapSet.new()
        |> MapSet.size()

      count == 1
    end

    @doc """
    Max entries percent variance relative to the mean
    """
    def max_variance_percent([]), do: cast_decimal(100)
    def max_variance_percent([_]), do: cast_decimal(100)

    def max_variance_percent(list) when is_list(list) do
      mean = decimal_avg(list)

      cond do
        is_decimal_uniform(list) ->
          cast_decimal(100)

        Decimal.cmp(mean, 0) == :eq ->
          cast_decimal(0)

        true ->
          list
          |> Enum.map(&cast_decimal!/1)
          |> Enum.map(&decimal_sub(&1, mean))
          |> Enum.max_by(&Decimal.abs/1)
          |> decimal_div(mean)
          |> as_percentage()
          |> decimal_add(100)
      end
    end

    @doc """
    Annualize a monthly amount
    """
    def annualize(x), do: decimal_mult(x, 12)

    def rounded?(amount, round_up: factor) when is_integer(factor) and factor > 0 do
      rem =
        amount
        |> cast_decimal()
        |> Decimal.rem(cast_decimal(factor))

      Decimal.cmp(rem, Decimal.new(0)) == :eq
    end

    @doc """
    ((n + (factor/2)) / factor) * factor
    """
    def decimal_round(amount, round_up: factor) when is_integer(factor) and factor > 0 do
      if rounded?(amount, round_up: factor) do
        {:ok, cast_decimal(amount)}
      else
        rounded_amount =
          amount
          |> cast_decimal()
          |> Decimal.add(Decimal.div(factor, 2))
          |> Decimal.div(factor)
          |> Decimal.round()
          |> decimal_mult(factor)

        {:ok, rounded_amount}
      end
    end
  end
end
