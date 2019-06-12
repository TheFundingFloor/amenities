if Code.ensure_loaded?(Ecto) do
  defmodule Amenities.Ecto.Changesets do
    @moduledoc """
    Validation helpers for `Ecto.Changeset`.
    """

    import Ecto.Changeset

    require Logger

    @doc """
    Adds an single embed to an embeds_many assoc
    """
    def append_embed(changeset, field, embed) when is_atom(field) do
      put_embed(changeset, field, [embed | get_field(changeset, field)])
    end

    @doc """
    Applies a rename rule if the given `prev_atom` key is present in the map `params`.  It is changed to `next_atom`
    """
    def maybe_rename(params, prev_atom, next_atom)
        when is_map(params) and is_atom(prev_atom) and is_atom(next_atom) do
      prev_string = Atom.to_string(prev_atom)
      next_string = Atom.to_string(next_atom)

      case params do
        %{^prev_atom => value} -> Map.put(params, next_atom, value)
        %{^prev_string => value} -> Map.put(params, next_string, value)
        _ -> params
      end
    end

    # def maybe_put_assoc(%Ecto.Changeset{} = changeset, field, params)
    #     when is_atom(field) and is_map(params) do
    #   string_field = Atom.to_string(field)

    #   case params do
    #     %{^field => assoc} ->
    #       put_assoc(changeset, field, assoc)

    #     %{^string_field => assoc} ->
    #       put_assoc(changeset, field, assoc)

    #     _ ->
    #       changeset
    #   end
    # end

    def apply_changes_ok(%Ecto.Changeset{valid?: true} = changeset) do
      {:ok, apply_changes(changeset)}
    end

    def apply_changes_ok(%Ecto.Changeset{valid?: false} = changeset) do
      {:error, changeset}
    end

    def put_embed_if_loaded(changeset, field, %Ecto.Association.NotLoaded{}) do
      Logger.warn("[#{__MODULE__}] expected loaded embed, received: #{field}")
      changeset
    end

    def put_embed_if_loaded(changeset, field, struct) do
      put_embed(changeset, field, struct)
    end

    def put_computed_embed(%Ecto.Changeset{} = changeset, field, fun)
        when is_atom(field) and is_function(fun) do
      case Enum.find(changeset.types, fn {ecto_field, _ecto_type} -> ecto_field == field end) do
        {field, {:embed, %Ecto.Embedded{related: module}}} ->
          put_embed(changeset, field, fun.(changeset, module))

        nil ->
          raise "embed field expected for: #{field}"
      end
    end

    def put_change_if_valid(%Ecto.Changeset{} = changeset, field, change) when is_atom(field) do
      if changeset.valid? do
        put_change(changeset, field, change)
      else
        changeset
      end
    end
  end
end
