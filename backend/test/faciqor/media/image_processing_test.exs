defmodule Faciqor.Media.ImageProcessingTest do
  use ExUnit.Case, async: true
  alias Faciqor.Media.ImageProcessing

  describe "validate_avatar_or_logo/2" do
    test "accepts valid square 512x512 image" do
      # Create 512x512 black image
      {:ok, img} = Image.new(512, 512)
      {:ok, binary} = Image.write(img, :memory, suffix: ".png")

      assert {:ok, %{width: 512, height: 512}} = ImageProcessing.validate_avatar_or_logo(binary)
    end

    test "rejects non-square images" do
      {:ok, img} = Image.new(600, 400)
      {:ok, binary} = Image.write(img, :memory, suffix: ".png")

      assert {:error, {:not_square, 600, 400}} = ImageProcessing.validate_avatar_or_logo(binary)
    end

    test "rejects square images below 512px" do
      {:ok, img} = Image.new(256, 256)
      {:ok, binary} = Image.write(img, :memory, suffix: ".png")

      assert {:error, {:dimensions_too_small, 256, 256, 512}} =
               ImageProcessing.validate_avatar_or_logo(binary)
    end

    test "rejects files exceeding max size" do
      {:ok, img} = Image.new(512, 512)
      {:ok, binary} = Image.write(img, :memory, suffix: ".png")

      assert {:error, :file_too_large} =
               ImageProcessing.validate_avatar_or_logo(binary, max_size: 100)
    end
  end

  describe "generate_variants/3" do
    test "generates 64, 128, 256, 512 WebP variants" do
      {:ok, img} = Image.new(512, 512)
      {:ok, binary} = Image.write(img, :memory, suffix: ".png")

      assert {:ok, variants} = ImageProcessing.generate_variants(binary, [64, 128, 256, 512])

      assert is_binary(variants[64])
      assert is_binary(variants[128])
      assert is_binary(variants[256])
      assert is_binary(variants[512])

      # Verify generated variants are valid WebP images with correct dimensions
      {:ok, img64} = Image.open(variants[64])
      assert Image.width(img64) == 64
      assert Image.height(img64) == 64

      {:ok, img512} = Image.open(variants[512])
      assert Image.width(img512) == 512
      assert Image.height(img512) == 512
    end
  end
end
