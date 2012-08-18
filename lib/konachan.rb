class Konachan < Booru

  def initialize(tags, options)
    @data_url = "http://konachan.com"
    @referer = "http://konachan.com"
    super
  end

  def clean_url(url, md5)
    url = url.gsub(/http:\/\/.+\/image\/#{md5}\//, "")
    super
  end

end
