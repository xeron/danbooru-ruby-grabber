# coding: utf-8

# data examples
# http://danbooru.donmai.us/post/index.xml?limit=10&page=1&tags=konpaku_youmu
# http://konachan.com/post/index.xml?limit=10&page=1&tags=black_rock_shooter
# http://e621.net/post/index.xml?limit=10&page=1&tags=funny
# api here
# http://danbooru.donmai.us/help/api
# http://konachan.com/help/api
# http://e621.net/help/api

# Author: Ivan "Xeron" Larionov
# E-mail: xeron.oskom@gmail.com
# Homepage: http://xeron.13f.ru
# Version: 1.0

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'optparse'
require 'digest/sha1'
require 'digest/md5'

class Booru

  def initialize(tags, options)
    @user_agent = "Mozilla/5.0"
    @options = options
    @num = 1
    @page = 1
    @tag = tags.gsub(" ", "+")
    FileUtils.mkdir_p @tag
    FileUtils.mkdir_p @options[:storage] if @options[:storage]
    if @options[:storage]
      bbs_path = File.join(@options[:storage], "files.bbs")
    else
      bbs_path = File.join(@tag, "files.bbs")
    end
    @bbs = File.new(bbs_path, "a+")
    @old_file = @bbs.read
    get_data(@page)
    @count = @doc.root["count"]
    @pages = @count.to_i/100 + 1
  end

  def download_all
    while have_elements do
      download
      next_page
    end
    puts "Thats all for #{@tag}."
  end

  private

  def have_elements
    @posts.size > 0
  end

  def next_page
    @page += 1
    puts "Switching to page #{@page} of #{@pages}"
    get_data(@page)
  end

  def get_data(page_num)
    data = ""
    while data.empty?
      begin
        data = open("#{@data_url}/post/index.xml?limit=100&page=#{page_num}&tags=#{@tag}&login=#{@options[:user]}&password_hash=#{@options[:password]}", "User-Agent" => @user_agent).read
      rescue => ex
        puts "Error reading data — #{ex}"
        sleep 2
      end
    end
    @doc = Nokogiri::XML(data)
    @posts = @doc.xpath("//posts/post")
  end

  def write_tags(filename, tags)
    @bbs.puts "#{filename} - #{tags}"
  end

  def clean_url(url, md5)
    url = url.gsub("%20"," ")
    return url
  end

  def get_url(post)
    url = post["file_url"]
  end

  def download
    @posts.each do |post|
      url = get_url(post)
      md5 = post["md5"]
      filename = clean_url(url, md5)
      @options[:storage] ? real_filename = File.join(@options[:storage], filename) : real_filename = File.join(@tag, filename)
      tags = post["tags"]
      if File.exist?(real_filename) && md5 == Digest::MD5.hexdigest(File.read(real_filename))
        puts "File exist - #{real_filename} (#{@num}/#{@count})"
      else
        puts "saving #{real_filename}... (#{@num}/#{@count})"
        if @options[:wget]
          `wget -nv '#{url}' -O '#{real_filename}' --user-agent=#{@user_agent} --referer='#{@referer}'`
        elsif @options[:curl]
          `curl -A #{@user_agent} -e #{@referer} --progress-bar -o '#{real_filename}' '#{url}'`
        else
          open(real_filename,"wb").write(open(url, "User-Agent" => @user_agent, "Referer" => @referer).read)
        end
        puts "saved!"
      end
      FileUtils.ln_sf(File.join("..", real_filename), File.join(@tag, filename)) if @options[:storage]
      write_tags(filename, tags) if !@old_file.include?(filename)
      @num += 1
    end
  end

end