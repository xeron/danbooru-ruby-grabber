class Behoimi < Booru

  def initialize(tags, options)
    super
    self.api_base_url = "http://behoimi.org"
    self.password_salt = "meganekko-heaven"
    # @referer = "http://behoimi.org/post/show"
  end

  # def clean_url(url, md5)
  #   strings = ["http://behoimi.org/"]
  #   strings.each do |str|
  #     url = url.gsub(str, "")
  #   end
  #   url = url.gsub(/data\/.{2}\/.{2}\//,"")
  #   super
  # end

end
