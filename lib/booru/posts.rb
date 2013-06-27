class Booru

  LIMIT = 100

  # Get posts
  # http://danbooru.donmai.us/posts.json?limit=100&page=1&tags=touhou&login=USER&password_hash=PASSWORD
  # === Returns
  # Array:: Hashes of found posts
  def posts(page = 1, limit = LIMIT)
    do_request("posts.json", {:tags => tags, :page => page, :limit => limit})
  end

  # Get posts count
  # http://danbooru.donmai.us/counts/posts.json?tags=touhou&login=USER&password_hash=PASSWORD
  # === Returns
  # Integer:: Number of posts
  def posts_count
    do_request("counts/posts.json", {:tags => tags})["counts"]["posts"]
  end

  # Download all posts
  def download_all
    count = posts_count
    pages = count/LIMIT + 1
    num = 1
    pages.times do |i|
      page = i + 1
      puts "Page #{page}/#{pages}:"
      posts(page, LIMIT).each do |post|
        download(post, num, count)
        num +=1
      end
    end
  end

  private

  def download(post, num, count)
    url = get_url(post)
    filename = get_filename(url)
    md5 = post["md5"]
    tag_string = post["tag_string"]
    path = if options[:storage]
      File.join(options[:storage], filename)
    else
      File.join(tags, filename)
    end
    if File.exist?(path) && md5 == Digest::MD5.hexdigest(File.read(path))
      puts "File exist - #{path} (#{num}/#{count})"
    else
      puts "saving #{path}... (#{num}/#{count})"
      download_with_tool(url, path)
      puts "saved!"
    end
    FileUtils.ln_sf(File.join("..", path), File.join(tags, filename)) if options[:storage]
    write_tags(filename, tag_string) unless @old_bbs.include?(filename)
  end

  def get_url(post)
    api_base_url + post["file_url"]
  end

  def get_filename(url)
    File.basename(URI.parse(url).path)
  end

  def download_with_tool(url, path)
    case options[:downloader]
    when :wget
      `wget -nv "#{url}" -O "#{path}" --user-agent="#{USER_AGENT}" --referer="#{api_base_url}"`
    when :curl
      `curl -A "#{USER_AGENT}" -e "#{api_base_url}" --progress-bar -o "#{path}" "#{url}"`
    else
      open(path, "wb").write(open(url, "User-Agent" => USER_AGENT, "Referer" => api_base_url).read)
    end
  end

  def write_tags(filename, tags)
    @bbs.puts "#{filename} - #{tags}"
  end

end
