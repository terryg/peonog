class Main
  get "/" do
    @redis = monk_settings(:redis)
    haml :home
  end

  get "/series/:id" do
    @name = params[:id].upcase
    @assets = Asset.all('series.name' => @name, :order => [ :weight.asc ])
    haml :thumbs
  end

  get "/works/:id" do
    @name = params[:id]
    @assets = paginate(Asset.all(:year => @name, :deleted => false, :order => [ :weight.asc ]))
    haml :thumbs
  end

  get "/paintings" do
    @assets = paginate(Asset.all(:deleted => false, :order => [ :weight.asc ]))
    haml :thumbs
  end

  get "/paintings/view/:id" do
    @asset = Asset.get(params[:id])
    assets = Asset.all(:deleted => false, :order => [ :weight.asc ])
    assets.each_with_index do |a,index|
      if a.id == @asset.id
        @prev_id = assets[index-1].id if index > 0 and assets[index-1]
        @next_id = assets[index+1].id if index < assets.size and assets[index+1]
      end
    end
    haml :asset
  end

  get "/oysters" do
    haml :oysters
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
      asset = Asset.create(:title => params[:title],
                           :year => params[:year],
                           :media => params[:media],
                           :width => params[:width].to_i*25.4,
                           :height => params[:height].to_i*25.4,
                           :series_id => series.id,
                           :weight => 100)

      asset.store_on_s3(params['myfile'][:tempfile], 
                        params['myfile'][:filename])
    end

    haml :upload
  end
end
