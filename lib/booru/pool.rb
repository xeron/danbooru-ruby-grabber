class Booru
  # Get pool by id
  # http://danbooru.donmai.us/pools/1.json
  # https://yande.re/pool/show.json?id=1&page=1
  # === Returns
  # Hash:: Pool data
  def pool(id, page = 1)
    if self.class::OLD_API
      do_request('pool/show.json', id: id, page: page)
    else
      do_request("pools/#{id}.json")
    end
  end

  def download_by_pool(id)
    if self.class::OLD_API
      data = pool(id)
      pool_data = data['pool'] || data.reject { |k| k == 'posts' }
    else
      pool_data = pool(id)
    end
    puts "Pool name: #{pool_data['name']}."
    pool_dir = sanitize_filename(pool_data['name'])
    FileUtils.mkdir_p pool_dir

    bbs_path = File.join(options[:storage] || pool_dir, 'files.bbs')
    bbs = File.new(bbs_path, 'a+')
    old_bbs = bbs.read

    count = pool_data['post_count']
    if count.zero?
      puts 'No posts, nothing to do.'
    else
      num = 1
      if self.class::OLD_API
        pages = (count.to_f / data['posts'].count).ceil
        1.upto(pages) do |page|
          puts "Page #{page}/#{pages}:"
          pool(id, page)['posts'].each do |post_data|
            download_post(post_data, pool_dir, num, count, bbs, old_bbs)
            num += 1
          end
        end
      else
        pool_data['post_ids'].each do |post_id|
          post_data = post(post_id)
          download_post(post_data, pool_dir, num, count, bbs, old_bbs)
          num += 1
        end
      end
    end
  end
end
