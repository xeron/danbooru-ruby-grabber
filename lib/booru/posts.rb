class Booru
  # Get post by id
  # Only new API
  # http://danbooru.donmai.us/posts/$id.json
  # === Returns
  # Hash:: Data of found post
  def post(id)
    only_new_api
    do_request("posts/#{id}.json")
  end

  # Get posts by tags
  # http://danbooru.donmai.us/posts.json?tags=touhou&page=1&limit=100
  # https://yande.re/post.json?tags=touhou&page=1&limit=100
  # === Returns
  # Array:: Hashes of found posts
  def posts_by_tags(tags, page = 1, limit = options[:limits][:per_page])
    tags = clean_tags(tags)
    posts_url = self.class::OLD_API ? 'post.json' : 'posts.json'
    do_request(posts_url, tags: tags, page: page, limit: limit)
  end

  # Get posts count by tag
  # http://danbooru.donmai.us/counts/posts.json?tags=touhou
  # https://yande.re/post/index.xml?tags=touhou&limit=1
  # === Returns
  # Integer:: Number of posts
  def posts_count_by_tag(tags)
    tags = clean_tags(tags)
    if self.class::OLD_API
      do_request('post/index.xml', { tags: tags, limit: 1 }, :get, nil, :xml).root['count'].to_i
    else
      do_request('counts/posts.json', tags: tags)['counts']['posts']
    end
  end

  def download_by_tags(tags)
    tags = clean_tags(tags)
    tags_dir = sanitize_filename(tags)
    puts "Tags are #{tags}."
    FileUtils.mkdir_p tags_dir

    bbs_path = File.join(options[:storage] || tags_dir, 'files.bbs')
    bbs = File.new(bbs_path, 'a+')
    old_bbs = bbs.read

    count = posts_count_by_tag(tags)
    if count.zero?
      puts 'No posts, nothing to do.'
    else
      pages = (count.to_f / options[:limits][:per_page]).ceil
      pages = options[:limits][:pages] if options[:limits][:pages] && options[:limits][:pages] < pages
      num = 1
      1.upto(pages) do |page|
        puts "Page #{page}/#{pages}:"
        posts_by_tags(tags, page, options[:limits][:per_page]).each do |post_data|
          download_post(post_data, tags_dir, num, count, bbs, old_bbs)
          num += 1
        end
      end
    end
  end

  private

  def download_post(post_data, target, num, count, bbs, old_bbs)
    exit if options[:limits][:posts] && options[:limits][:posts] < num

    # Prepare post data
    if post_data['file_url']
      url = get_url(post_data['file_url'])
      md5 = post_data['md5']
    else
      url, md5 = get_data_from_html(post_data['id'])
      return nil if url.nil?
    end
    filename = get_filename(post_data, md5, url)
    tag_string = self.class::OLD_API ? post_data['tags'] : post_data['tag_string']

    path =
      if options[:storage]
        File.join(options[:storage], filename)
      else
        File.join(target, filename)
      end
    if File.exist?(path) && md5 == Digest::MD5.hexdigest(File.read(path))
      puts "File exists - #{path} (#{num}/#{count})"
    else
      puts "Saving #{path}... (#{num}/#{count})"
      download_with_tool(url, path)
      puts 'saved!'
    end
    FileUtils.ln_sf(File.join('..', path), File.join(target, filename)) if options[:storage]
    write_tags(filename, tag_string, bbs) unless old_bbs =~ /^#{filename}/
  end

  def get_url(file_url)
    if file_url =~ URI::DEFAULT_PARSER.make_regexp
      file_url
    elsif file_url.start_with?(self.class::API_BASE_URL.gsub('http:', ''))
      'http:' + file_url
    else
      self.class::API_BASE_URL + file_url
    end
  end

  def get_data_from_html(id)
    print "File url is unknown for #{id}. Trying HTML... "
    begin
      html_data = open(self.class::API_BASE_URL + "/posts/#{id}")
      nokogiri_data = Nokogiri::HTML(html_data)
      file_url = nokogiri_data.css('section #image-container').first['data-file-url']
      md5 = nokogiri_data.css('section #image-container').first['data-md5']
      result = [get_url(file_url), md5]
      puts 'success!'
    rescue StandardError
      puts 'fail. Giving up.'
      result = [nil, nil]
    end
    result
  end

  def get_filename(post_data, md5, url)
    real_filename = CGI.unescape(File.basename(URI.parse(url).path))
    ext = File.extname(real_filename)

    case options[:filename]
    when :md5
      md5 + ext
    when :tags
      tags_key = self.class::OLD_API ? 'tags' : 'tag_string'
      post_data[tags_key] + ext
    when :url
      real_filename
    else
      post_data['id'].to_s + ext
    end
  end

  def download_with_tool(url, path)
    case options[:downloader]
    when :wget
      `wget -nv "#{url}" -O "#{path}" --user-agent="#{USER_AGENT}" --referer="#{@referer}"`
    when :curl
      `curl -L -A "#{USER_AGENT}" -e "#{@referer}" --progress-bar -o "#{path}" "#{url}"`
    else
      open(path, 'wb').write(open(url, 'rb', 'User-Agent' => USER_AGENT, 'Referer' => @referer).read)
    end
  end

  def write_tags(filename, tags, bbs)
    bbs.puts "#{filename} - #{tags}"
  end

  def clean_tags(tags)
    tags.tr(' ', '+')
  end
end
