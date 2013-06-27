# coding: utf-8

$:.unshift File.dirname(__FILE__)
require "booru/base"
require "booru/posts"

# class Booru

#   def initialize(tags, options)
#     @num = 1
#     @page = 1
#     @tag = if @options[:pool]
#       @options[:pool]
#     else
#       tags.gsub(" ", "+")
#     end
#     FileUtils.mkdir_p @tag
#     if @options[:storage]
#       FileUtils.mkdir_p @options[:storage]
#       bbs_path = File.join(@options[:storage], "files.bbs")
#     else
#       bbs_path = File.join(@tag, "files.bbs")
#     end
#     @bbs = File.new(bbs_path, "a+")
#     @old_bbs = @bbs.read
#     get_data(@page)
#     @count = if @options[:pool]
#       @doc.root["post_count"]
#     else
#       @doc.root["count"]
#     end
#     if @posts.size > 0
#       @pages = @count.to_i/@posts.size + 1
#     else
#       puts "No posts for #{@tag}."
#       exit
#     end
#   end

#   def download_all
#     while have_elements? do
#       download
#       next_page
#     end
#     puts "Thats all for #{@tag}."
#   end

#   private

#   def have_elements?
#     @posts.size > 0
#   end

#   def next_page
#     @page += 1
#     puts "Switching to page #{@page} of #{@pages}"
#     get_data(@page)
#   end

#   def get_data(page_num)
#     data = ""
#     uri = if @options[:pool]
#       URI.escape("#{@data_url}/pool/show.xml?page=#{page_num}&id=#{@tag}&login=#{@options[:user]}&password_hash=#{@options[:password]}")
#     else
#       URI.escape("#{@data_url}/post/index.xml?limit=100&page=#{page_num}&tags=#{@tag}&login=#{@options[:user]}&password_hash=#{@options[:password]}")
#     end
#     while data.empty?
#       begin
#         data = open(uri, "User-Agent" => @user_agent).read
#       rescue => ex
#         puts "Error reading data — #{ex}"
#         sleep 2
#       end
#     end
#     @doc = Nokogiri::XML(data)
#     @posts = @doc.xpath("//posts/post")
#   end

# end
