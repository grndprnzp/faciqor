defmodule Faciqor.Operations.AddressExpander do
  @moduledoc """
  Parser und Expander für Hausnummern-Bereiche, Komma-Listen, Buchstabensuffixe
  und Eckgrundstücks-Eingaben gemäß REQ-M2-FACILITIES § 4.3.
  """

  alias Faciqor.Operations.TitleBuilder

  @max_range_size 100

  @doc """
  Expandiert einen Hausnummern-Ausdruck (z. B. `"10-13"`, `"10a-c"`, `"10a-10c"`, `"123, 125, 127"`)
  unter Berücksichtigung des Filters (`:all`, `:even`, `:odd`) in eine geordnete Liste einzelner Hausnummern.

  ## Beispiele
      iex> AddressExpander.expand_house_numbers("10-13", :all)
      {:ok, ["10", "11", "12", "13"]}

      iex> AddressExpander.expand_house_numbers("10-14", :even)
      {:ok, ["10", "12", "14"]}

      iex> AddressExpander.expand_house_numbers("10a-c", :all)
      {:ok, ["10a", "10b", "10c"]}

      iex> AddressExpander.expand_house_numbers("123, 125, 127", :all)
      {:ok, ["123", "125", "127"]}
  """
  def expand_house_numbers(expr, filter \\ :all) when is_binary(expr) do
    segments =
      expr
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    if segments == [] do
      {:error, :empty_house_number}
    else
      segments
      |> Enum.reduce_while({:ok, []}, fn seg, {:ok, acc} ->
        case expand_segment(seg, filter) do
          {:ok, nums} -> {:cont, {:ok, acc ++ nums}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
      |> case do
        {:ok, list} ->
          uniq = Enum.uniq(list)

          if uniq == [] do
            {:error, :no_matching_house_numbers}
          else
            {:ok, uniq}
          end

        err ->
          err
      end
    end
  end

  @doc """
  Zerlegt eine freie Adress- oder Bereichseingabe wie
  `"Hauptstraße 10-13, 10115 Berlin"` oder `"Lauterberger Straße 32 / Walkenrieder Straße 4, Berlin"`
  in einzelne Suchanfragen je Teiladresse.
  """
  def expand_address_query(query, filter \\ :all) when is_binary(query) do
    {street_block, location_tail} =
      case String.split(query, ",", parts: 2) do
        [s, tail] -> {String.trim(s), String.trim(tail)}
        [s] -> {String.trim(s), ""}
      end

    # Unterstützung für Eckgrundstücke getrennt durch "/"
    corner_segments =
      street_block
      |> String.split("/", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    corner_segments
    |> Enum.reduce_while({:ok, []}, fn segment, {:ok, acc} ->
      case expand_single_street_segment(segment, location_tail, filter) do
        {:ok, items} -> {:cont, {:ok, acc ++ items}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp expand_single_street_segment(segment, location_tail, filter) do
    cond do
      # US-Style: "123 Main Street"
      match = Regex.run(~r/^(\d+[a-zA-Z]?)\s+([a-zA-ZäöüÄÖÜß].+)$/u, segment) ->
        [_, num_expr, street] = match
        build_expanded_queries(String.trim(street), String.trim(num_expr), location_tail, filter)

      # Deutsches Format mit Bereich/Liste am Ende: "Hauptstraße 10-13" oder "Gartenweg 10a-c" oder "Hauptstraße 10, 12"
      match = Regex.run(~r/^(.+?)\s+(\d+[a-zA-Z]?(?:\s*-\s*\d*[a-zA-Z]?)?)$/u, segment) ->
        [_, street, num_expr] = match
        build_expanded_queries(String.trim(street), String.trim(num_expr), location_tail, filter)

      true ->
        full = if location_tail != "", do: "#{segment}, #{location_tail}", else: segment
        {:ok, [%{street_hint: segment, house_number_hint: nil, query: full}]}
    end
  end

  defp build_expanded_queries(street, num_expr, location_tail, filter) do
    case expand_house_numbers(num_expr, filter) do
      {:ok, numbers} ->
        items =
          Enum.map(numbers, fn num ->
            base = "#{street} #{num}"
            full = if location_tail != "", do: "#{base}, #{location_tail}", else: base
            %{street_hint: street, house_number_hint: num, query: full}
          end)

        {:ok, items}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp expand_segment(seg, filter) do
    cond do
      # Buchstabensuffix-Bereich wie "10a-10c" oder "10a-c"
      match = Regex.run(~r/^(\d+)\s*([a-zA-Z])\s*-\s*(?:(\d+)\s*)?([a-zA-Z])$/, seg) ->
        [_, start_num_s, start_let, end_num_s, end_let] = match
        start_num = String.to_integer(start_num_s)
        end_num = if end_num_s == "" or is_nil(end_num_s), do: start_num, else: String.to_integer(end_num_s)

        c1 = :binary.first(String.downcase(start_let))
        c2 = :binary.first(String.downcase(end_let))

        if start_num != end_num or c2 < c1 or c2 - c1 > 25 do
          {:error, :invalid_suffix_range}
        else
          nums =
            for c <- c1..c2 do
              "#{start_num}#{<<c>>}"
            end

          {:ok, apply_parity_filter(nums, filter)}
        end

      # Numerischer Bereich wie "10-13"
      match = Regex.run(~r/^(\d+)\s*-\s*(\d+)$/, seg) ->
        [_, s_str, e_str] = match
        s_num = String.to_integer(s_str)
        e_num = String.to_integer(e_str)

        cond do
          e_num < s_num ->
            {:error, :range_end_before_start}

          e_num - s_num + 1 > @max_range_size ->
            {:error, :range_too_large}

          true ->
            nums =
              s_num..e_num
              |> Enum.map(&Integer.to_string/1)
              |> apply_parity_filter(filter)

            {:ok, nums}
        end

      # Einzelne Hausnummer wie "32" oder "10a"
      Regex.match?(~r/^\d+\s*[a-zA-Z]?$/, seg) ->
        {_num, _suf, canonical} = TitleBuilder.parse_house_number(seg)
        {:ok, [canonical]}

      true ->
        {:error, {:invalid_house_number_format, seg}}
    end
  end

  defp apply_parity_filter(nums, :all), do: nums

  defp apply_parity_filter(nums, :even) do
    Enum.filter(nums, fn s ->
      {n, _, _} = TitleBuilder.parse_house_number(s)
      rem(n, 2) == 0
    end)
  end

  defp apply_parity_filter(nums, :odd) do
    Enum.filter(nums, fn s ->
      {n, _, _} = TitleBuilder.parse_house_number(s)
      rem(n, 2) != 0
    end)
  end

  defp apply_parity_filter(nums, _), do: nums
end
