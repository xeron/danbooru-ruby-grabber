class Danbooru < Booru

  def initialize(tags, options)
    @data_url = "http://danbooru.donmai.us"
    super
  end

  def clean_url(url, md5)
    strings = ["http://s3.amazonaws.com/danbooru/",
    "http://danbooru.donmai.us/data/"]
    strings.each do |str|
      url = url.gsub(str, "")
    end
    super
  end

end