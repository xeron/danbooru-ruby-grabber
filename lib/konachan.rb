class Konachan < Booru

  def initialize(tags, options)
    super
    self.api_base_url = "http://konachan.com"
    self.password_salt = "So-I-Heard-You-Like-Mupkids-?"
  end

  # def clean_url(url, md5)
  #   url = url.gsub(/http:\/\/.+\/image\/#{md5}\//, "")
  #   super
  # end

end
