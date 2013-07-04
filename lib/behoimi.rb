class Behoimi < Booru

  API_BASE_URL = "http://behoimi.org"
  PASSWORD_SALT = "meganekko-heaven"
  OLD_API = true
  REFERER = "http://behoimi.org/post/show"

  # def clean_url(url, md5)
  #   strings = ["http://behoimi.org/"]
  #   strings.each do |str|
  #     url = url.gsub(str, "")
  #   end
  #   url = url.gsub(/data\/.{2}\/.{2}\//,"")
  #   super
  # end

end
