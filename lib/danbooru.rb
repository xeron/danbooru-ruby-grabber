class Danbooru < Booru

  def initialize(tags, options)
    @data_url = "http://danbooru.donmai.us"
    @referer = "http://danbooru.donmai.us"
    super
  end

  def clean_url(url, md5)
    url = url.gsub(/http:\/\/.+\/.+\//, "")
    super
  end

end
