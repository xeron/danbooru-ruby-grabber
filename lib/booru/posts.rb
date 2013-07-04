class Booru

  LIMIT = 100

  # Get posts
  # http://danbooru.donmai.us/posts.json?limit=100&page=1&tags=touhou&login=USER&password_hash=PASSWORD
  # https://yande.re/post.json?limit=100&page=1&tags=touhou&login=USER&password_hash=PASSWORD
  # === Returns
  # Array:: Hashes of found posts
  def posts(page = 1, limit = LIMIT)
    posts_url = self.class::OLD_API ? "post.json" : "posts.json"
    do_request(posts_url, {:tags => tags, :page => page, :limit => limit})
  end

  # Get posts count
  # http://danbooru.donmai.us/counts/posts.json?tags=touhou&login=USER&password_hash=PASSWORD
  # === Returns
  # Integer:: Number of posts
  def posts_count
    if self.class::OLD_API
      do_request("post.xml", {:tags => tags, :limit => 1}, :get, nil, :xml).root["count"]
    else
      do_request("counts/posts.json", {:tags => tags})["counts"]["posts"]
    end
  end

  # Download all posts
  def download_all
    count = posts_count
    if count == 0
      puts "No posts, nothing to do."
    else
      pages = (count.to_f/LIMIT).ceil
      num = 1
      1.upto(pages) do |page|
        puts "Page #{page}/#{pages}:"
        posts(page, LIMIT).each do |post|
          download(post, num, count)
          num += 1
        end
      end
    end
  end

  private

  def download(post, num, count)
    url = get_url(post["file_url"])
    filename = get_filename(url)
    md5 = post["md5"]
    tag_string = post["tag_string"]
    path = if options[:storage]
      File.join(options[:storage], filename)
    else
      File.join(tags, filename)
    end
    if File.exist?(path) && md5 == Digest::MD5.hexdigest(File.read(path))
      puts "File exists - #{path} (#{num}/#{count})"
    else
      puts "saving #{path}... (#{num}/#{count})"
      download_with_tool(url, path)
      puts "saved!"
    end
    FileUtils.ln_sf(File.join("..", path), File.join(tags, filename)) if options[:storage]
    write_tags(filename, tag_string) unless @old_bbs.include?(filename)
  end

  def get_url(file_url)
    if file_url =~ /^#{URI::regexp}$/
      file_url
    else
      self.class::API_BASE_URL + file_url
    end
  end

  def get_filename(url)
    CGI.unescape(File.basename(URI.parse(url).path))
  end

  def download_with_tool(url, path)
    case options[:downloader]
    when :wget
      `wget -nv "#{url}" -O "#{path}" --user-agent="#{USER_AGENT}" --referer="#{@referer}"`
    when :curl
      `curl -A "#{USER_AGENT}" -e "#{@referer}" --progress-bar -o "#{path}" "#{url}"`
    else
      open(path, "wb").write(open(url, "User-Agent" => USER_AGENT, "Referer" => @referer).read)
    end
  end

  def write_tags(filename, tags)
    @bbs.puts "#{filename} - #{tags}"
  end

end
