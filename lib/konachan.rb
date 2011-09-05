class Konachan < Booru

  def initialize(tags, options)
    @data_url = "http://konachan.com"
    @referer = "http://konachan.com"
    super
  end

  def clean_url(url, md5)
    strings = ["http://kuro.hanyuu.net/image/#{md5}/",
    "http://konachan.com/image/#{md5}/",
    "http://kana.hanyuu.net/image/#{md5}/",
    "http://victorica.hanyuu.net/image/#{md5}/"]
    strings.each do |str|
      url = url.gsub(str, "")
    end
    super
  end

end