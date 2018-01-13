defmodule Standup.CloudexImageHelper do
  import Phoenix.HTML.Tag

  def cl_image_tag(public_id, options \\ []) do
    transformation_options = %{}
    if Keyword.has_key?(options, :transforms) do
      transformation_options = Map.merge(%{}, options[:transforms])
    end

    image_tag_options = Keyword.delete(options, :transforms)

    picture_width = transformation_options[:width] || 100
    picture_height = transformation_options[:height] || 100

    defaults = [
      src: Cloudex.Url.for(public_id, transformation_options),
      width: picture_width,
      height: picture_height,
      alt: "image with name #{public_id}"
    ]

    attributes = Keyword.merge(defaults, image_tag_options)

    tag(:img, attributes)
  end
end