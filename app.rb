require 'sinatra'
require 'logger'
require 'sass'

require './helpers'
require './models/asset'
require './models/series'

DataMapper.finalize

class App < Sinatra::Base
  use Rack::Session::Cookie, :key => 'rack.session', :secret => 'this-is-the-patently-secret-thing'
  enable :methodoverride
  helpers Helpers
  
  set :logging, Logger::DEBUG
  
  before do
    if request.env['HTTP_HOST'].match(/herokuapp\.com/)
      redirect 'http://www.laramirandagoodman.com', 301
    end
  end

  get "/assets/:id" do
    @asset = Asset.get(params[:id].to_i)
    redirect "/assets" if @asset.nil?
    @full_url = "http://www.laramirandagoodman.com/paintings/view/#{@asset.id}"
    assets = Asset.all(:deleted => false, :order => [ :weight.asc ])
    assets.each_with_index do |a,index|
      if a.id == @asset.id
        @prev_id = assets[index-1].id if index > 0 and assets[index-1]
        @next_id = assets[index+1].id if index < assets.size and assets[index+1]
      end
    end 
    
    if params[:edit] == "on"
      haml :asset_form
    else
      haml :asset
    end
  end

  post "/assets/:id" do
    asset = Asset.get(params[:id].to_i)
    asset.update_from_form(params)
    redirect "/assets/#{params[:id]}", 301
  end

  get "/gallery" do
    @series = Series.all(:order => :id.desc)
    haml :gallery
  end
	
  get "/slideshow" do
    @assets = Asset.all(:deleted.not => TRUE, :order => :weight.asc)
    haml :slideshow
  end

  get "/pricelist" do
    @assets = Asset.all(:deleted.not => TRUE, :sold.not => TRUE, :order => :weight.asc)
    haml :pricelist
  end

  get "/" do
    @home = "1"
    @full_url = "http://www.laramirandagoodman.com"
    @series = Series.all(:order => :id.desc)
    haml :home
  end

  get "/css/:stylesheet.css" do
    content_type "text/css", :charset => "UTF-8"
    sass :"css/#{params[:stylesheet]}"
  end

  get "/series/:id" do
    @uri = "series/#{params[:id]}"
    @name = params[:id].upcase
    @assets = paginate(Asset.all('series.name' => @name, :deleted => false, :order => [ :weight.asc ]))
    haml :thumbs
  end

  get "/works/:id" do
    @uri = "works/#{params[:id]}"
    @name = params[:id]
    @assets = paginate(Asset.all(:year => @name, :deleted => false, :order => [ :weight.asc ]))
    haml :thumbs
  end

  get "/paintings" do
    @uri = "paintings"
    @assets = paginate(Asset.all(:deleted => false, :order => [ :weight.asc ]))
    haml :thumbs
  end

  get "/CV" do
    haml :cv
  end

  get "/contact" do
    @address = "artist@laramirandagoodman.com"
    haml :contact
  end

  get "/admin" do
    @assets = Asset.all(:deleted => false, :order => [ :weight.asc ])
    @weights = {}
    @assets.each do |asset|
      @weights[asset.id] = asset.weight
    end
    haml :admin
  end

  post "/admin" do
    if params['password'] == ENV['UPLOAD_PASSWORD']
      @assets = Asset.all(:deleted => false, :order => [ :weight.asc ])
      @weights = {}
      @assets.each do |asset|
        if params["weight_#{asset.id}"]
          asset.weight = params["weight_#{asset.id}"]
          asset.save
          @weights[asset.id] = asset.weight
        end
        if params["delete_#{asset.id}"]
          asset.destroy
        end
      end
    end
    haml :admin
  end

  get "/upload" do
    haml :upload
  end

  post "/upload" do
    if params['password'] == ENV['UPLOAD_PASSWORD']
      series = Series.first_or_create(:name => params[:series])
      heaviest = Asset.first(:deleted => false, :order => [ :weight.desc ]) 
      weight = heaviest.weight unless heaviest.nil?
      weight ||= 0
      
      asset = Asset.create(:title => params[:title],
                           :year => params[:year],
                           :media => params[:media],
                           :width => params[:width].to_i*25.4,
                           :height => params[:height].to_i*25.4,
                           :series_id => series.id,
                           :weight => weight + 10)

      asset.store_on_s3(params['myfile'][:tempfile], 
                        params['myfile'][:filename])
    end

    haml :upload
  end
end
