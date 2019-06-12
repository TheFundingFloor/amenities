if Code.ensure_loaded?(Decimal) do
  defmodule Amenities.DecimalsTest do
    use ExUnit.Case, async: true

    alias Amenities.Decimals

    describe ".variance_percent/1" do
      test "with 0 numbers" do
        values = []
        assert Decimals.variance_percent(values) == Decimals.cast_decimal("0")
      end

      test "with 1 number" do
        values = [25_000]
        assert Decimals.variance_percent(values) == Decimals.cast_decimal("100")
      end

      test "with multiple same numbers" do
        values = [500, 500, 500]
        assert Decimals.variance_percent(values) == Decimals.cast_decimal("100")
      end

      test "with multiple similar numbers" do
        values = [500, 510, 520]

        assert Decimals.variance_percent(values) ==
                 Decimals.cast_decimal("101.307692307692307692307692308")
      end

      test "with multiple diverging numbers" do
        values = [500, 5_000, 25_000]

        assert Decimals.variance_percent(values) ==
                 Decimals.cast_decimal("798.6666666666666666666666667")
      end

      test "with multiple numbers including a 0" do
        values = [0, 5_000, 25_000, 25_000, 35_000, 45_000, 88_888]

        assert Decimals.variance_percent(values) ==
                 Decimals.cast_decimal("199.587318211141295086420252")
      end

      test "with [100, 200, 240]" do
        values = [100, 200, 240]

        assert Decimals.variance_percent(values) ==
                 Decimals.cast_decimal("138.3333333333333333333333333")
      end
    end

    describe ".max_variance_percent/1" do
      test "with []" do
        values = []
        assert Decimals.max_variance_percent(values) == Decimals.cast_decimal("100")
      end

      test "with [0]" do
        values = [0]
        assert Decimals.max_variance_percent(values) == Decimals.cast_decimal("100")
      end

      test "with [100, 200, 240]" do
        values = [100, 200, 240]

        assert Decimals.max_variance_percent(values) ==
                 Decimals.cast_decimal("55.55555555555555555555555556")
      end

      test "with [180, 200, 300]" do
        values = [180, 200, 300]

        assert Decimals.max_variance_percent(values) ==
                 Decimals.cast_decimal("132.3529411764705882352941176")
      end

      test "with [0, 0, 0] (mean = 0 but all equal)" do
        values = [0, 0, 0]
        assert Decimals.max_variance_percent(values) == Decimals.cast_decimal("100")
      end

      test "with [-2, 2, 0] (mean = 0)" do
        values = [-2, 2, 0]
        assert Decimals.max_variance_percent(values) == Decimals.cast_decimal("0")
      end
    end
  end
end
