class Asset
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :year, String
  property :media, String
  property :width, Float
  property :height, Float
  property :s3_original, String
  property :s3_300, String
  property :s3_500, String
  property :s3_thumb, String
  property :weight, Integer
  property :deleted, Boolean, :required => true, :default => false
  property :sold, Boolean, :required => true, :default => false

  belongs_to :series

  attr_accessor :temp_filename

  def process(fname, sizing, ext, attribute_sym)
    image = MiniMagick::Image.open(fname)
    image.resize(sizing)
    image.write(fname)
      
    value = (0...16).map{(97+rand(26)).chr}.join
    fkey = value + ext

    AWS::S3::S3Object.store(fkey, open(fname), ENV['S3_BUCKET_NAME'])
    update(attribute_sym => fkey) 
  end

  def store_on_s3(temp_file, filename)
    value = (0...16).map{(97+rand(26)).chr}.join
    ext = File.extname(filename)
    fkey = value  + ext
    fname = 'public/uploads/' + fkey
    File.open(fname, "w") do |f|
      f.write(temp_file.read)
    end

    AWS::S3::S3Object.store(fkey, open(fname), ENV['S3_BUCKET_NAME'])
    update(:s3_original => fkey)
    save

    process(fname, "300x1000", ext, :s3_300)
    process(fname, "500x2000", ext, :s3_500)
    process(fname, "150x1000", ext, :s3_thumb)
  end

  def s3_bucket
    'http://s3.amazonaws.com/' + ENV['S3_BUCKET_NAME'] + '/'
  end

  def url
    s3_bucket + s3_original if s3_original
  end

  def url_500
    s3_bucket + s3_500 if s3_500
  end

  def url_300
    s3_bucket + s3_300 if s3_300
  end

  def url_thumb
    s3_bucket + s3_thumb if s3_thumb
  end

  def alt_text
    "%s. %dx%d. %s. %s. %s" % [title, height_in, width_in, media, year, (sold) ? 'SOLD' : '']
  end

  def text_html
    "<em>%s</em>, %s. %s. %d x %d inches. %s" % [title, year, media, height_in, width_in, (sold) ? 'SOLD' : '']
  end

  def title_year_html
    "<em>%s</em>, %s." % [title, year]
  end

  def dim
    "%d x %d inches" % [height_in, width_in]
  end

  def width_in
    width / 25.4
  end

  def height_in
    height / 25.4
  end

end


