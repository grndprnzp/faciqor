defmodule Faciqor.Operations.TitleBuilder do
  @moduledoc """
  Deterministische Synthese des Objekttitels (`facility.title`) aus den zugehörigen
  Teiladressen (`FacilityAddress`) gemäß REQ-M2-FACILITIES § 4.2.
  """

  @doc """
  Berechnet den Titel eines Objekts aus einer Liste von Adress-Maps oder `FacilityAddress`-Structs.

  ## Beispiele
      iex> TitleBuilder.build_title([
      ...>   %{street: "Lauterberger Straße", house_number: "32"},
      ...>   %{street: "Walkenrieder Straße", house_number: "4"}
      ...> ])
      "Lauterberger Straße 32 - Walkenrieder Straße 4"

      iex> TitleBuilder.build_title([
      ...>   %{street: "Main Street", house_number: "123"},
      ...>   %{street: "Main Street", house_number: "125"},
      ...>   %{street: "Main Street", house_number: "127"}
      ...> ])
      "Main Street 123,125,127"

      iex> TitleBuilder.build_title([
      ...>   %{street: "Hauptstraße", house_number: "10"},
      ...>   %{street: "Hauptstraße", house_number: "11"},
      ...>   %{street: "Hauptstraße", house_number: "12"},
      ...>   %{street: "Hauptstraße", house_number: "13"}
      ...> ])
      "Hauptstraße 10-13"
  """
  def build_title(addresses) when is_list(addresses) do
    normalized =
      addresses
      |> Enum.map(&normalize_entry/1)
      |> Enum.reject(fn {street, _} -> street == "" end)

    street_order =
      normalized
      |> Enum.map(&elem(&1, 0))
      |> Enum.uniq_by(&String.downcase/1)

    grouped =
      Enum.group_by(
        normalized,
        fn {street, _parsed_num} -> String.downcase(street) end,
        fn {street, parsed_num} -> {street, parsed_num} end
      )

    street_order
    |> Enum.map(fn canonical_street ->
      entries = Map.get(grouped, String.downcase(canonical_street), [])
      display_street = entries |> List.first() |> elem(0)

      numbers_str =
        entries
        |> Enum.map(&elem(&1, 1))
        |> Enum.reject(fn {_n, _s, raw} -> raw == "" end)
        |> Enum.uniq_by(fn {n, s, raw} -> {n, s || "", String.downcase(raw)} end)
        |> Enum.sort_by(fn {n, s, _raw} -> {n, s || ""} end)
        |> format_number_runs()

      if numbers_str == "" do
        display_street
      else
        "#{display_street} #{numbers_str}"
      end
    end)
    |> Enum.join(" - ")
  end

  @doc """
  Zerlegt eine Hausnummer (z. B. `"32"`, `"10a"`, `"10 A"`) in `{numeric, suffix, canonical_string}`.
  """
  def parse_house_number(nil), do: {0, nil, ""}

  def parse_house_number(raw) when is_binary(raw) do
    trimmed = String.trim(raw)

    case Regex.run(~r/^(\d+)\s*([a-zA-Z])?$/, trimmed) do
      [_, num_str] ->
        num = String.to_integer(num_str)
        {num, nil, Integer.to_string(num)}

      [_, num_str, suffix] ->
        num = String.to_integer(num_str)
        norm_suf = String.downcase(suffix)
        {num, norm_suf, "#{num}#{norm_suf}"}

      _ ->
        case Integer.parse(trimmed) do
          {num, rest} ->
            clean_rest = String.trim(rest) |> String.downcase()
            suf = if clean_rest == "", do: nil, else: clean_rest
            {num, suf, if(suf, do: "#{num}#{suf}", else: "#{num}")}

          :error ->
            {0, nil, trimmed}
        end
    end
  end

  def parse_house_number(num) when is_integer(num), do: {num, nil, Integer.to_string(num)}

  @doc """
  Extrahiert Straßenname und Hausnummer sowohl aus deutschem Format (`"Hauptstraße 10a"`)
  als auch aus US/UK-Format (`"123 Main Street"`).
  """
  def extract_street_and_number(input) when is_binary(input) do
    # Nur den Teil vor dem ersten Komma betrachten (falls PLZ/Stadt enthalten ist)
    street_segment =
      input
      |> String.split(",", parts: 2)
      |> List.first("")
      |> String.trim()

    cond do
      # US/UK Format: "123 Main Street" -> {"Main Street", "123"}
      match = Regex.run(~r/^(\d+[a-zA-Z]?)\s+([a-zA-ZäöüÄÖÜß].+)$/u, street_segment) ->
        [_, num, street] = match
        {String.trim(street), String.trim(num)}

      # Deutsches Format: "Lauterberger Straße 32a" -> {"Lauterberger Straße", "32a"}
      match = Regex.run(~r/^(.+?)\s+(\d+\s*[a-zA-Z]?)$/u, street_segment) ->
        [_, street, num] = match
        {String.trim(street), String.replace(num, ~r/\s+/, "")}

      true ->
        {street_segment, ""}
    end
  end

  defp normalize_entry(entry) when is_map(entry) do
    raw_street = to_string(Map.get(entry, :street) || Map.get(entry, "street") || "") |> String.trim()
    raw_num = to_string(Map.get(entry, :house_number) || Map.get(entry, "house_number") || "") |> String.trim()

    {street, num} =
      cond do
        raw_num == "" and raw_street != "" ->
          extract_street_and_number(raw_street)

        # Falls in `street` versehentlich "123 Main Street" übergeben wurde
        Regex.match?(~r/^\d+[a-zA-Z]?\s+[a-zA-Z]/, raw_street) ->
          {extracted_street, extracted_num} = extract_street_and_number(raw_street)
          {extracted_street, if(raw_num != "", do: raw_num, else: extracted_num)}

        true ->
          {raw_street, raw_num}
      end

    {street, parse_house_number(num)}
  end

  defp format_number_runs([]), do: ""

  defp format_number_runs(parsed_numbers) do
    runs =
      Enum.reduce(parsed_numbers, [], fn item, acc ->
        case acc do
          [] ->
            [[item]]

          [current_run | rest_runs] ->
            prev = List.last(current_run)

            if consecutive?(prev, item) do
              [current_run ++ [item] | rest_runs]
            else
              [[item], current_run | rest_runs]
            end
        end
      end)
      |> Enum.reverse()

    Enum.map_join(runs, ",", fn
      [single] ->
        elem(single, 2)

      run when length(run) >= 2 ->
        first_str = run |> List.first() |> elem(2)
        last_str = run |> List.last() |> elem(2)
        "#{first_str}-#{last_str}"
    end)
  end

  defp consecutive?({n1, nil, _}, {n2, nil, _}) when n1 > 0 and n2 == n1 + 1, do: true

  defp consecutive?({n1, s1, _}, {n2, s2, _})
       when n1 > 0 and n1 == n2 and is_binary(s1) and is_binary(s2) and byte_size(s1) == 1 and byte_size(s2) == 1 do
    :binary.first(s2) == :binary.first(s1) + 1
  end

  defp consecutive?(_, _), do: false
end
