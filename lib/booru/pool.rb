class Booru

  # Get pool by id
  # http://danbooru.donmai.us/pools/1.json
  # https://yande.re/pool/show.json?id=1&page=1
  # === Returns
  # Hash:: Pool data
  def pool(id, page = 1)
    id = clean_pool_id(id)
    if self.class::OLD_API
      do_request("pool/show.json", {:id => id, :page => page})
    else
      do_request("pools/#{id}.json")
    end
  end

  def download_by_pool(id)
    if self.class::OLD_API
      data = pool(id)
      pool_data = data["pool"] || data.select { |k| k != "posts" }
    else
      pool_data = pool(id)
    end
    name = pool_data["name"]
    puts "Pool name: #{name}."
    FileUtils.mkdir_p name

    bbs_path = File.join(options[:storage] || name, "files.bbs")
    bbs = File.new(bbs_path, "a+")
    old_bbs = bbs.read

    count = pool_data["post_count"]
    if count == 0
      puts "No posts, nothing to do."
    else
      num = 1
      if self.class::OLD_API
        pages = (count.to_f/data["posts"].count).ceil
        1.upto(pages) do |page|
          puts "Page #{page}/#{pages}:"
          pool(id, page)["posts"].each do |post_data|
            download_post(post_data, name, num, count, bbs, old_bbs)
            num += 1
          end
        end
      else
        pool_data["post_ids"].split.each do |post_id|
          post_data = post(post_id)
          download_post(post_data, name, num, count, bbs, old_bbs)
          num += 1
        end
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
