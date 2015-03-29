class E621 < Booru

  API_BASE_URL = "https://e621.net"
  PASSWORD_SALT = nil
  OLD_API = true

  def posts_by_tags(tags, page = 1, limit = LIMIT)
    tags = clean_tags(tags)
    posts_url = "post/index.json"
    do_request(posts_url, {:tags => tags, :page => page, :limit => limit})
  end

end
