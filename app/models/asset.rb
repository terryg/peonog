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
    "%s. %.2fx%.2f. %s. %s." % [title, height_in, width_in, media, year]
  end

  def text
    "%s, %s. %s. %.1f x %.1f inches" % [title, year, media, height_in, width_in]
  end

  def width_in
    width / 25.4
  end

  def height_in
    height / 25.4
  end

end


