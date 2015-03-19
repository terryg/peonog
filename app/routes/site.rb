class Main
  before do
    logger.level = 0
  end

  get "/" do
    @redis = monk_settings(:redis)
    @full_url = "http://www.laramirandagoodman.com"
    @share_text = "Enjoyed art by Lara Miranda Goodman"
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
		
		redirect "/paintings" if @asset.nil?

		@full_url = "http://www.laramirandagoodman.com/paintings/view/#{@asset.id}"
    @share_text = "Enjoyed viewing '#{@asset.title}' by Lara Miranda Goodman"

    assets = Asset.all(:deleted => false, :order => [ :weight.asc ])
    assets.each_with_index do |a,index|
      if a.id == @asset.id
        @prev_id = assets[index-1].id if index > 0 and assets[index-1]
        @next_id = assets[index+1].id if index < assets.size and assets[index+1]
      end
    end
    haml :asset
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
		logger.debug "XXXXXX"
		logger.debug params
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
