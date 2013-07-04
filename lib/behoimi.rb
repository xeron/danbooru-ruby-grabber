class Behoimi < Booru

  API_BASE_URL = "http://behoimi.org"
  PASSWORD_SALT = "meganekko-heaven"
  OLD_API = true
  REFERER = "http://behoimi.org/post/show"

  def initialize(tag, opts)
    super
    @referer = REFERER
  end

  def posts(page = 1, limit = LIMIT)
    posts_url = "post/index.json"
    do_request(posts_url, {:tags => tags, :page => page, :limit => limit})
  end

  def posts_count
    do_request("post/index.xml", {:tags => tags, :limit => 1}, :get, nil, :xml).root["count"]
  end

end
