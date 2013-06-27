class Danbooru < Booru

  def initialize(tag, opts)
    super
    self.api_base_url = "http://danbooru.donmai.us"
  end

end
