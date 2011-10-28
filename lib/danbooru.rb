class Danbooru < Booru

  def initialize(tags, options)
    @data_url = "http://danbooru.donmai.us"
    @referer = "http://danbooru.donmai.us"
    super
  end

  def clean_url(url, md5)
    # old method
    # strings = [
    #   "http://s3.amazonaws.com/danbooru/",
    #   "http://danbooru.donmai.us/data/",
    #   "http://hijiribe.donmai.us/data/",
    #   "http://sonohara.donmai.us/data/"
    # ]
    # strings.each do |str|
    #   url = url.gsub(str, "")
    # end
    url = url.gsub(/http:\/\/.+\/.+\//, "")
    super
  end

end