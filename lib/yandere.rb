class Yandere < Booru

  def initialize(tags, options)
    @data_url = "https://yande.re"
    @referer = "https://yande.re"
    super
  end

  def clean_url(url, md5)
    url = url.gsub(/https:\/\/.+\/image\/#{md5}\//, "")
    super
  end

end
