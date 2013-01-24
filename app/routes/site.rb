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
      filepath = 'public/uploads/' + params['myfile'][:filename]
      File.open(filepath, "w") do |f|
        f.write(params['myfile'][:tempfile].read)

        series = Series.first_or_create(:name => params[:series])
        Asset.create(:title => params[:name],
                     :year => params[:year],
                     :media => params[:media],
                     :width => params[:width],
                     :height => params[:height],
                     :path_to_img => "/" + filepath,
                     :series_id => series.id)
                                       
      end
    end
  end
end
