class Behoimi < Booru

  def initialize(tags, options)
    @data_url = "http://behoimi.org"
    @referer = "http://behoimi.org/post/show"
    super
  end

  def clean_url(url, md5)
    strings = ["http://behoimi.org/"]
    strings.each do |str|
      url = url.gsub(str, "")
    end
    url = url.gsub(/data\/.{2}\/.{2}\//,"")
    super
  end

end
