defmodule Faciqor.Operations.TitleBuilderAndExpanderTest do
  use ExUnit.Case, async: true

  alias Faciqor.Operations.{AddressExpander, TitleBuilder}

  describe "4.2 TitleBuilder.build_title/1" do
    test "formats corner property (Eckgrundstück): Lauterberger Straße 32 / Walkenrieder Straße 4" do
      addresses = [
        %{street: "Lauterberger Straße", house_number: "32"},
        %{street: "Walkenrieder Straße", house_number: "4"}
      ]

      assert TitleBuilder.build_title(addresses) == "Lauterberger Straße 32 - Walkenrieder Straße 4"
    end

    test "formats multiple house numbers with gaps (mit Unterbrechung): 123 Main Street, 125 Main Street, 127 Main Street" do
      addresses = [
        %{street: "123 Main Street", house_number: ""},
        %{street: "125 Main Street", house_number: ""},
        %{street: "127 Main Street", house_number: ""}
      ]

      assert TitleBuilder.build_title(addresses) == "Main Street 123,125,127"
    end

    test "formats consecutive house numbers (ohne Unterbrechung): Hauptstraße 10-13" do
      addresses = [
        %{street: "Hauptstraße", house_number: "10"},
        %{street: "Hauptstraße", house_number: "11"},
        %{street: "Hauptstraße", house_number: "12"},
        %{street: "Hauptstraße", house_number: "13"}
      ]

      assert TitleBuilder.build_title(addresses) == "Hauptstraße 10-13"
    end

    test "formats consecutive letter suffixes: Gartenweg 10a-10c" do
      addresses = [
        %{street: "Gartenweg", house_number: "10a"},
        %{street: "Gartenweg", house_number: "10b"},
        %{street: "Gartenweg", house_number: "10c"}
      ]

      assert TitleBuilder.build_title(addresses) == "Gartenweg 10a-10c"
    end

    test "formats mixed runs and corner properties" do
      addresses = [
        %{street: "Berliner Allee", house_number: "10"},
        %{street: "Berliner Allee", house_number: "11"},
        %{street: "Berliner Allee", house_number: "12"},
        %{street: "Berliner Allee", house_number: "15"},
        %{street: "Seestraße", house_number: "2"}
      ]

      assert TitleBuilder.build_title(addresses) == "Berliner Allee 10-12,15 - Seestraße 2"
    end
  end

  describe "4.3 AddressExpander" do
    test "expands numeric ranges with :all, :even, :odd filters" do
      assert {:ok, ["10", "11", "12", "13"]} = AddressExpander.expand_house_numbers("10-13", :all)
      assert {:ok, ["10", "12", "14"]} = AddressExpander.expand_house_numbers("10-14", :even)
      assert {:ok, ["11", "13", "15"]} = AddressExpander.expand_house_numbers("10-15", :odd)
    end

    test "expands letter suffix ranges and comma lists" do
      assert {:ok, ["10a", "10b", "10c"]} = AddressExpander.expand_house_numbers("10a-c", :all)
      assert {:ok, ["10a", "10b", "10c"]} = AddressExpander.expand_house_numbers("10a-10c", :all)
      assert {:ok, ["123", "125", "127"]} = AddressExpander.expand_house_numbers("123, 125, 127", :all)
    end

    test "expands full address query with corner segments and ranges" do
      assert {:ok, items} =
               AddressExpander.expand_address_query(
                 "Lauterberger Straße 32 / Walkenrieder Straße 4-5, 10115 Berlin",
                 :all
               )

      assert length(items) == 3
      assert Enum.at(items, 0).query == "Lauterberger Straße 32, 10115 Berlin"
      assert Enum.at(items, 1).query == "Walkenrieder Straße 4, 10115 Berlin"
      assert Enum.at(items, 2).query == "Walkenrieder Straße 5, 10115 Berlin"
    end
  end
end
