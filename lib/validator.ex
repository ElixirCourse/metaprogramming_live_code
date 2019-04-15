defmodule Validator.Struct do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :validators, accumulate: true)
      @before_compile Validator.Struct
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def valid?(struct) do
        Validator.valid?(struct, @validators)
      end
    end
  end

  defmacro validate(field, operation) do
    quote do
      @validators {unquote(field), unquote(operation)}
    end
  end
end

defmodule Validator do
  def valid?(struct, validators) do
    validators
    # TODO: HOMEWORK
    # |> Enum.group_by(fn {field, validation} -> field end)
    |> Enum.map(fn
      {field, [{function, args}]} ->
        apply_rule(function, Map.get(struct, field), args)

      {field, operation} ->
        apply_rule(operation, Map.get(struct, field))
    end)
    |> Enum.reject(&match?(:ok, &1))
    |> case do
      [] ->
        :ok

      list ->
        errors = Enum.map(list, fn {:error, error} -> error end)

        {:error, errors}
    end
  end

  defp apply_rule(fun, value) when is_function(fun, 1) do
    case fun.(value) do
      x when x in [nil, false] -> {:error, "sorry"}
      _ -> :ok
    end
  end

  defp apply_rule(:length, value, min..max) when is_binary(value) do
    case String.length(value) do
      len when len >= min and len <= max -> :ok
      len -> {:error, ~s/Length of "#{value}" must be bettween #{min} and #{max}/}
    end
  end

  defp apply_rule(:length, value, min..max) when is_list(value) do
    case length(value) do
      len when len >= min and len <= max ->
        :ok

      len ->
        {:error, ~s/Length of "#{value}" must be bettween #{min} and #{max}/}
    end
  end

  defp apply_rule(:length, value, _) do
    {:error, ~s/Cannot calculate length of "#{inspect(value)}" - it must be binary or list/}
  end

  defp apply_rule(:valid_email, email) when is_binary(email) do
    case Regex.match?(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, email) do
      true -> :ok
      false -> {:error, "#{email} is not a valid email"}
    end
  end

  defp apply_rule(:valid_email, email) when is_binary(email) do

  defp apply_rule(:excludes, value, list) do
    case Enum.member?(list, value) do
      false -> :ok
      true -> {:error, "#{value} is not allowed value"}
    end
  end
end
