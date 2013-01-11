class Main
  get "/" do
    @redis = monk_settings(:redis)
    haml :home
  end

  get "/Landscapes" do
    haml :landscapes
  end

  get "/Oysters" do
    haml :oysters
  end

  get "/CV" do
    haml :cv
  end

  get "/Contact" do
    haml :contact
  end

end
