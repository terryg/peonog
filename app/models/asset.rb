class Asset
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :year, String
  property :media, String
  property :width, Float
  property :height, Float
  property :path_to_img, String

  belongs_to :series

  def alt_text
    "#{title}. #{width_in}x#{height_in}. #{media}. #{year}."
  end

  def text_html
    "<em>#{title}</em>, #{year}. #{media}. #{width_in} x #{height_in} inches"
  end

  def width_in
    width / 25.4
  end

  def height_in
    height / 25.4
  end

end


