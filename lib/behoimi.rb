class Behoimi < Booru
  API_BASE_URL = 'http://behoimi.org'
  PASSWORD_SALT = 'meganekko-heaven'
  API_KEY = false
  OLD_API = true
  REFERER = 'http://behoimi.org/post/show'

  def initialize(opts)
    super
    @referer = REFERER
  end

  def posts_by_tags(tags, page = 1, limit = LIMIT)
    tags = clean_tags(tags)
    posts_url = 'post/index.json'
    do_request(posts_url, tags: tags, page: page, limit: limit)
  end
end
