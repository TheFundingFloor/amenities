if Code.ensure_loaded?(Ecto) do
  defmodule Amenities.Ecto.Validations do
    @moduledoc """
    Validation helpers for `Ecto.Changeset`.
    """

    import Ecto.Changeset

    @doc """
    Validates that a `changeset` `field` has required fields if true
    """
    @spec validate_if(Ecto.Changeset.t(), atom, [atom]) :: Ecto.Changeset.t()
    def validate_if(changeset, field, fields) when is_atom(field) and is_list(fields) do
      case get_field(changeset, field) do
        true ->
          validate_required(changeset, fields)

        _ ->
          changeset
      end
    end

    @doc """
    Validates that a `changeset` `field` has required fields if true
    """
    @spec validate_length_if(Ecto.Changeset.t(), atom, atom, keyword()) :: Ecto.Changeset.t()
    def validate_length_if(changeset, field, field2, opts)
        when is_atom(field) and is_atom(field2) and is_list(opts) do
      case get_field(changeset, field) do
        true ->
          case {get_field(changeset, field2), Keyword.get(opts, :min)} do
            {[], min} when is_integer(min) and min > 0 ->
              add_error(changeset, field2, "can't be blank")

            _ ->
              validate_length(changeset, field2, opts)
          end

        _ ->
          changeset
      end
    end

    @doc """
    Validates that a `changeset` `field` relation has at least `min_count` associations.
    """
    @spec validate_assoc_count(Ecto.Changeset.t(), atom, number) :: Ecto.Changeset.t()
    def validate_assoc_count(changeset, field, min_count) do
      case assoc_count(changeset, field) >= min_count do
        true -> changeset
        _ -> add_error(changeset, field, "should have at least #{min_count}")
      end
    end

    defp assoc_count(changeset, field) do
      changeset
      |> get_field(field, [])
      |> length
    end

    @doc """
    Validates that a `changeset` `min_field` is less than the `max_field` when both exist
    """
    @spec validate_min_max(Ecto.Changeset.t(), atom, atom) :: Ecto.Changeset.t()
    @spec validate_min_max(Ecto.Changeset.t(), atom, atom, String.t()) :: Ecto.Changeset.t()
    def validate_min_max(changeset, min_field, max_field) do
      message = "#{min_field} cannot be greater than #{max_field}"
      validate_min_max(changeset, min_field, max_field, message)
    end

    def validate_min_max(changeset, min_field, max_field, message) do
      min = get_field(changeset, min_field)
      max = get_field(changeset, max_field)

      if is_nil(min) || is_nil(max) || min < max do
        changeset
      else
        add_error(changeset, min_field, message)
      end
    end

    @doc """
    Validates that a `changeset` `field` has a valid ssn.
    """
    @spec validate_ssn(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
    def validate_ssn(changeset, field) do
      ssn = get_field(changeset, field)

      changeset
      |> do_validate_ssn(field, ssn)
    end

    @spec do_validate_ssn(Ecto.Changeset.t(), atom, String.t()) :: Ecto.Changeset.t()
    defp do_validate_ssn(changeset, _field, ssn) when is_nil(ssn), do: changeset

    defp do_validate_ssn(changeset, field, ssn) when is_binary(ssn) do
      case Regex.scan(~r/\d/, ssn) do
        match when length(match) == 9 ->
          put_change(changeset, field, Enum.join(match))

        _ ->
          add_error(changeset, field, "SSN is not valid")
      end

      # match = Regex.scan(~r/\d/, ssn)

      # if length(match) == 9 do
      #   changeset
      #   |> put_change(field, Enum.join(match))
      # else
      #   add_error(changeset, field, "SSN is not valid")
      # end
    end

    # @doc """
    # Validates that a `changeset` `field` has an address that is parsable by
    #   `AddressUS.Parser.parse_address/1`.
    # """
    # @spec validate_address(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
    # def validate_address(%Ecto.Changeset{valid?: false} = changeset, field), do: changeset

    # def validate_address(%Ecto.Changeset{valid?: true} = changeset, field) do
    #   address =
    #     changeset
    #     |> get_field(field)
    #     |> AddressUS.Parser.parse_address()

    #   changeset
    #   |> do_validate_primary_street_number(field, address.street && address.street.primary_number)
    #   |> do_validate_street_name(field, address.street && address.street.name)
    #   |> do_validate_city(field, address.city)
    #   |> do_validate_state(field, address.state)
    #   |> do_validate_postal(field, address.postal)
    # end

    # @spec do_validate_primary_street_number(Ecto.Changeset.t(), atom, String.t()) ::
    #         Ecto.Changeset.t()
    # defp do_validate_primary_street_number(changeset, field, primary_street_number)
    #      when is_nil(primary_street_number) do
    #   add_error(
    #     changeset,
    #     field,
    #     "No Primary Street Number Provided",
    #     section: :primary_street_number
    #   )
    # end

    # defp do_validate_primary_street_number(changeset, field, primary_street_number), do: changeset

    # @spec do_validate_street_name(Ecto.Changeset.t(), atom, String.t()) :: Ecto.Changeset.t()
    # defp do_validate_street_name(changeset, field, street_name) when is_nil(street_name) do
    #   add_error(changeset, field, "No Street Name Provided", section: :street_name)
    # end

    # defp do_validate_street_name(changeset, field, street_name), do: changeset

    # @spec do_validate_city(Ecto.Changeset.t(), atom, String.t()) :: Ecto.Changeset.t()
    # defp do_validate_city(changeset, field, city) when is_nil(city) do
    #   add_error(changeset, field, "No City Provided", section: :city)
    # end

    # defp do_validate_city(changeset, field, city), do: changeset

    # @spec do_validate_state(Ecto.Changeset.t(), atom, String.t()) :: Ecto.Changeset.t()
    # defp do_validate_state(changeset, field, state) when is_nil(state) do
    #   add_error(changeset, field, "No State Provided", section: :state)
    # end

    # defp do_validate_state(changeset, field, state), do: changeset

    # @spec do_validate_postal(Ecto.Changeset.t(), atom, String.t()) :: Ecto.Changeset.t()
    # defp do_validate_postal(changeset, field, postal) when is_nil(postal) do
    #   add_error(changeset, field, "No postal Provided", section: :postal)
    # end

    # defp do_validate_postal(changeset, field, postal), do: changeset

    @doc """
    Validates that a valid `changeset` `field` value equals `value`, otherwise adds an error.
    """
    @spec validate_field_is(Ecto.Changeset.t(), atom, any) :: Ecto.Changeset.t()
    def validate_field_is(changeset, field, value) do
      {_, current} = Ecto.Changeset.fetch_field(changeset, field)

      if current == value do
        changeset
      else
        # add_error(changeset, field, "expected #{value} for #{field} but got #{current}")
        add_error(changeset, field, "invalid #{field}")
      end
    end

    @doc """
    Validates that a valid `changeset` `field` value equals `value`, otherwise adds an error.
    """
    @spec validate_acceptance_unless_nil(Ecto.Changeset.t(), atom, based_on: atom) ::
            Ecto.Changeset.t()
    def validate_acceptance_unless_nil(changeset, field, based_on: based_on_field) do
      case get_field(changeset, based_on_field) do
        nil -> changeset
        _ -> validate_acceptance(changeset, field)
      end
    end

    @doc """
    Changes a `changeset` `field` value, to equal `value` when current value equals `to`
    """
    @spec put_transition(Ecto.Changeset.t(), atom, from: String.t(), to: String.t()) ::
            Ecto.Changeset.t()
    def put_transition(changeset, field, from: from, to: to) do
      case get_field(changeset, field) do
        ^from ->
          changeset
          |> put_change_when_valid(field, to)

        _ ->
          changeset
      end
    end

    @doc """
    Changes a `changeset` `field` value, to equal `value` when current value equals `to`
    """
    @spec put_transition_on_match(Ecto.Changeset.t(), atom, from: any, to: any) ::
            Ecto.Changeset.t()
    def put_transition_on_match(changeset, field, from: from, to: to) do
      with value <- get_field(changeset, field),
           true <- do_put_transition_match?(from, value) do
        changeset
        |> put_change(field, to)
      else
        _ -> changeset
      end
    end

    defp do_put_transition_match?(from, value) when is_list(from), do: Enum.member?(from, value)
    defp do_put_transition_match?(from, value), do: from == value

    # @doc """
    # Validates that a valid `changeset` `field` has changed
    # """
    # @spec validate_change_on(Ecto.Changeset.t, atom) :: Ecto.Changeset.t
    # def validate_change_on(changeset, field) do
    #   if get_change(changeset, field)
    # end

    @doc """
    Validates that a valid `changeset` `field` value equals `value`, otherwise adds an error.
    """
    @spec validate_transition(Ecto.Changeset.t(), atom, from: String.t(), to: String.t()) ::
            Ecto.Changeset.t()
    def validate_transition(changeset, field, from: from, to: to) do
      changeset
      |> validate_field_is(field, from)
      |> put_change_when_valid(field, to)
    end

    @spec validate_transition(Ecto.Changeset.t(), atom, not_from: String.t(), to: String.t()) ::
            Ecto.Changeset.t()
    def validate_transition(changeset, field, not_from: not_from, to: to) do
      case get_field(changeset, field) do
        ^not_from ->
          add_error(changeset, field, "invalid transition")

        _ ->
          put_change(changeset, field, to)
      end
    end

    def put_change_when_valid(%Ecto.Changeset{valid?: true} = changeset, field, value) do
      changeset
      |> put_change(field, value)
    end

    def put_change_when_valid(changeset, _field, _value), do: changeset

    # def validate_phone(changeset, field, opts \\ []) when is_atom(field) do
    #   case Phone.parse(changeset.changes[field], :us) do
    #     {:ok, phone}     ->
    #       case opts[:format] do
    #         true -> put_change(changeset, field, phone.area_code <> phone.number)
    #         _ -> changeset
    #       end
    #     {:error, error}  -> add_error(changeset, field, error)
    #   end
    # end

    @doc """
    Validates that a valid `changeset` `field` value is of :size, otherwise adds an error.
    """
    @spec validate_map_size(Ecto.Changeset.t(), atom, min: integer) :: Ecto.Changeset.t()
    def validate_map_size(changeset, field, min: min) when is_integer(min) do
      {_, current} = Ecto.Changeset.fetch_field(changeset, field)

      cond do
        !is_map(current) ->
          add_error(changeset, field, "expected #{field} to be a map")

        map_size(current) >= min ->
          changeset

        true ->
          add_error(changeset, field, "expected #{field} to be at least #{min}")
      end
    end
  end
end
