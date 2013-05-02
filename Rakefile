require './init'

desc 'Default task: run all tests'
task :default => [:test]

task :test do
  exec "thor monk:test"
end

desc 'Creates the 150 width images for existing assets'
task :make_asset_150s do
  assets = Asset.all(:deleted => false)
  assets.each do |asset|
    p asset.url
    orig = MiniMagick::Image.open(asset.url)
    orig.size "150"
    orig.write "localcopy.jpg"
    
    value = (0...16).map{(97+rand(26)).chr}.join
    fkey = value + ".jpg"
    
    AWS::S3::S3Object.store(fkey, open("localcopy.jpg"), ENV['S3_BUCKET_NAME'])
    asset.update(:s3_150 => fkey)
    asset.save
  end
end	      

