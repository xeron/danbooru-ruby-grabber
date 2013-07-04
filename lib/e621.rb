class E621 < Booru

  API_BASE_URL = "http://e621.net"
  PASSWORD_SALT = nil
  OLD_API = true

  def posts(page = 1, limit = LIMIT)
    posts_url = "post/index.json"
    do_request(posts_url, {:tags => tags, :page => page, :limit => limit})
  end

end
