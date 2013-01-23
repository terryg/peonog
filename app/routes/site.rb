class Main
  get "/" do
    @redis = monk_settings(:redis)
    haml :home
  end

  get "/series/:id" do
    @name = params[:id].upcase
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
      File.open('public/uploads/' + params['myfile'][:filename], "w") do |f|
        f.write(params['myfile'][:tempfile].read)
      end
    end
  end
end
