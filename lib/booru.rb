# coding: utf-8

require 'rubygems'
require 'open-uri'
require 'cgi'
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
    if @options[:storage]
      FileUtils.mkdir_p @options[:storage]
      bbs_path = File.join(@options[:storage], "files.bbs")
    else
      bbs_path = File.join(@tag, "files.bbs")
    end
    @bbs = File.new(bbs_path, "a+")
    @old_bbs = @bbs.read
    get_data(@page)
    @count = @doc.root["count"]
    @pages = @count.to_i/100 + 1
  end

  def download_all
    while have_elements? do
      download
      next_page
    end
    puts "Thats all for #{@tag}."
  end

  private

  def have_elements?
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
        data = open(URI.escape("#{@data_url}/post/index.xml?limit=100&page=#{page_num}&tags=#{@tag}&login=#{@options[:user]}&password_hash=#{@options[:password]}"), "User-Agent" => @user_agent).read
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
    CGI.unescape(url)
  end

  def get_url(post)
    url = post["file_url"]
  end

  def download
    @posts.each do |post|
      url = get_url(post)
      md5 = post["md5"]
      tags = post["tags"]
      filename = clean_url(url, md5)
      real_filename = @options[:storage] ? File.join(@options[:storage], filename) : File.join(@tag, filename)
      if File.exist?(real_filename) && md5 == Digest::MD5.hexdigest(File.read(real_filename))
        puts "File exist - #{real_filename} (#{@num}/#{@count})"
      else
        puts "saving #{real_filename}... (#{@num}/#{@count})"
        case @options[:downloader]
        when :wget
          `wget -nv "#{url}" -O "#{real_filename}" --user-agent="#{@user_agent}" --referer="#{@referer}"`
        when :curl
          `curl -A "#{@user_agent}" -e "#{@referer}" --progress-bar -o "#{real_filename}" "#{url}"`
        else
          open(real_filename, "wb").write(open(url, "User-Agent" => @user_agent, "Referer" => @referer).read)
        end
        puts "saved!"
      end
      FileUtils.ln_sf(File.join("..", real_filename), File.join(@tag, filename)) if @options[:storage]
      write_tags(filename, tags) unless @old_bbs.include?(filename)
      @num += 1
    end
  end

end
