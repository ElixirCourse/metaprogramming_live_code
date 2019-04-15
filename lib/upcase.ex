defmodule Upcase do
  @external_resource upcase_path = Path.join([__DIR__, "upcase.txt"])
  for line <- File.stream!(upcase_path, [], :line) do
    [big, small] = line |> String.trim() |> String.split(", ", trim: true)

    defp do_upcase(unquote(small)), do: unquote(big)
  end

  defp do_upcase(x), do: x

  def upcase(binary) do
    binary |> String.graphemes() |> Enum.map(&do_upcase/1) |> List.to_string()
  end
end
