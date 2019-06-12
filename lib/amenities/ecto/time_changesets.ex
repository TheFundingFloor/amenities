if Code.ensure_loaded?(Ecto) and Code.ensure_loaded?(Timex) do
  defmodule Amenities.Ecto.TimeChangesets do
    @moduledoc """
    Date and Time Helpers for `Ecto.Changeset`.
    """

    alias Amenities.Ecto.Validations

    import Ecto.Changeset

    @doc """
    Validates that a `changeset` `field` has a date that occurrs within a certain amount of recency.
    """
    @spec validate_date_recency(Ecto.Changeset.t(), atom, {:past, integer, :days}, String.t()) ::
            Ecto.Changeset.t()
    def validate_date_recency(
          %Ecto.Changeset{valid?: false} = changeset,
          _field,
          [:past, _allotted_days, :days],
          _message
        ),
        do: changeset

    def validate_date_recency(
          %Ecto.Changeset{valid?: true} = changeset,
          field,
          [:past, allotted_days, :days],
          message
        ) do
      date_diff =
        changeset
        |> get_field(field)
        |> Timex.diff(Timex.now(), :days)

      case date_diff <= allotted_days do
        true -> changeset
        _ -> add_error(changeset, field, message)
      end
    end

    @doc """
    Validates the `changeset` `field` value is in a current state `from`, then
      updates the value to `to` and writes the current timestamp to the `timestamp_field`.
    """
    @type transition :: {String.t(), String.t()}
    @spec validate_transition_with_timestamp(Ecto.Changeset.t(), atom, transition, atom) ::
            Ecto.Changeset.t()
    def validate_transition_with_timestamp(struct, field, {from, to}, timestamp_field) do
      struct
      |> validate_inclusion(field, [from])
      |> put_change(field, to)
      |> put_change(timestamp_field, Timex.now())
    end

    def put_current_timestamp_when_valid(changeset, field) do
      changeset
      |> Validations.put_change_when_valid(field, Timex.now())
    end
  end
end
