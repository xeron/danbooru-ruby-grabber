class Booru

  # Get post ids from pool
  # http://danbooru.donmai.us/pools/1.json?login=USER&password_hash=PASSWORD
  # === Returns
  # Array:: Numbers of post ids
  def pool(id)
    do_request("pools/#{clean_pool_id(id)}.json")
  end

  def download_by_pool(id)
    pool_data = pool(clean_pool_id(id))
    name = pool_data["name"]
    puts "Pool name: #{name}."

    FileUtils.mkdir_p name

    # Prepare BBS file
    bbs_path = File.join(name, "files.bbs")
    bbs = File.new(bbs_path, "a+")
    old_bbs = bbs.read

    count = pool_data["post_count"]
    if count == 0
      puts "No posts, nothing to do."
    else
      num = 1
      posts_by_ids(pool_data["post_ids"].split).each do |post|
        download_post(post, name, num, count, bbs, old_bbs)
        num += 1
      end
    end
  end

  private

  def clean_pool_id(id)
    if id.numeric_int? && id.to_i > 0
      id.to_i
    else
      $stderr.puts "-P should be a number and > 0. #{id} was given."
      exit 1
    end
  end

end

module NumericCheck
  def numeric_int?
    Integer(self) != nil rescue false
  end
end

class String
  include NumericCheck
end

class Integer
  include NumericCheck
end
