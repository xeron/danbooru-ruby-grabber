class E621 < Booru

  def initialize(tags, options)
    @data_url = "http://e621.net"
    @referer = "http://e621.net"
    super
  end

  def clean_url(url, md5)
    strings = ["http://e621.net/"]
    strings.each do |str|
      url = url.gsub(str, "")
    end
    url = url.gsub(/data\/.{2}\/.{2}\//,"")
    super
  end

  def get_url(post)
    url = @data_url + post["file_url"]
  end

end
