defmodule Standup.CloudexImageHelper do
  import Phoenix.HTML.Tag

  def cl_image_tag(public_id, options \\ []) do
    transformation_options = %{}
    if Keyword.has_key?(options, :transforms) do
      transformation_options = Map.merge(%{}, options[:transforms])
    end

    image_tag_options = Keyword.delete(options, :transforms)

    picture_width = 
        case transformation_options.width do
            nil -> 100
            _ -> transformation_options.width
        end
    picture_height = 
         case transformation_options.height do
            nil -> 100
            _ -> transformation_options.height
         end
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