class Series
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :description, Text

  has n, :assets
end


