defmodule Luma do
  def from_hash(string, opts \\ []) do
    default_color =
      case opts[:default] do
        nil -> "#000000"
        value -> value
      end

    low_luma =
      case opts[:low_luma] do
        nil -> 0
        value -> value
      end

    high_luma =
      case opts[:high_luma] do
        nil -> 255
        value -> value
      end

    hash = :crypto.hash(:md5, string) |> Base.encode16()
    acceptable_color_from_hash(hash, 0, default_color, low_luma, high_luma)
  end

  def is_acceptable(color, low, high) do
    {red, ""} = String.slice(color, 0, 2) |> Integer.parse(16)
    {green, ""} = String.slice(color, 2, 2) |> Integer.parse(16)
    {blue, ""} = String.slice(color, 4, 2) |> Integer.parse(16)
    luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue

    luma >= low and luma <= high
  end

  defp acceptable_color_from_hash(hash, start_index, default_color, low_luma, high_luma) do
    color = String.slice(hash, start_index, 6)
    case String.length(color) do
      6 ->
        case is_acceptable(color, low_luma, high_luma) do
          false -> acceptable_color_from_hash(hash, start_index + 1, default_color, low_luma, high_luma)
          true -> "##{color}"
        end
      _other -> default_color
    end
  end
end
