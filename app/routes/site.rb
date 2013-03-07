class Main
  get "/" do
    @redis = monk_settings(:redis)
    haml :home
  end

  get "/series/:id" do
    @name = params[:id].upcase
    @assets = Asset.all('series.name' => @name)
    haml :series
  end

  get "/works/:id" do
    @name = params[:id]
    @assets = Asset.all(:year => @name)
    haml :series
  end

  get "/paintings" do
    @page = if params[:page].nil?
              1
            else
              params[:page]
            end

    @assets = Asset.page @page, :per_page => 4
    haml :thumbs
  end

  get "/paintings/view/:id" do
    @asset = Asset.get(params[:id])
    a = Asset.first('deleted' => false, :id.lt => params[:id], :order => [ :id.desc ])
    @prev_id = a.id if a
    a = Asset.first('deleted' => false, :id.gt => params[:id], :order => [ :id.asc ])
    @next_id = a.id if a
    haml :asset
  end

  get "/oysters" do
    haml :oysters
  end

  get "/CV" do
    haml :cv
  end

  get "/contact" do
    haml :contact
  end

  get "/upload" do
    haml :upload
  end

  post "/upload" do
    if params['password'] == 'karlfardman'
      series = Series.first_or_create(:name => params[:series])
      asset = Asset.create(:title => params[:title],
                           :year => params[:year],
                           :media => params[:media],
                           :width => params[:width].to_i*25.4,
                           :height => params[:height].to_i*25.4,
                           :series_id => series.id)

      asset.store_on_s3(params['myfile'][:tempfile], 
                        params['myfile'][:filename])
    end

    haml :upload
  end
end
