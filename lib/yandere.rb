class Yandere < Booru

  def initialize(tags, options)
    super
    self.api_base_url = "https://yande.re"
  end

  # def clean_url(url, md5)
  #   url = url.gsub(/https:\/\/.+\/image\/#{md5}\//, "")
  #   super
  # end

end
