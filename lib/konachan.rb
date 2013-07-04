class Konachan < Booru

  API_BASE_URL = "http://konachan.com"
  PASSWORD_SALT = "So-I-Heard-You-Like-Mupkids-?"
  OLD_API = true

  # def clean_url(url, md5)
  #   url = url.gsub(/http:\/\/.+\/image\/#{md5}\//, "")
  #   super
  # end

end
