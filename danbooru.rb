# coding: utf-8

# data examples
# http://danbooru.donmai.us/post/index.xml?limit=10&page=1&tags=konpaku_youmu
# http://konachan.com/post/index.xml?limit=10&page=1&tags=black_rock_shooter
# api here
# http://danbooru.donmai.us/help/api
# http://konachan.com/help/api

# Author: Ivan "Xeron" Larionov
# E-mail: xeron.oskom@gmail.com
# Homepage: http://xeron.13f.ru
# Version: 0.7

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'optparse'
require 'digest/sha1'
require 'digest/md5'

class Danbooru

  def initialize(tags, options)
    @options = options
    @num = 1
    @page = 1
    @tag = tags.gsub(" ","+")
    FileUtils.mkdir_p @tag
    path = File.join(@tag,"files.bbs")
    @bbs = File.new(path,"a+")
    @old_file = @bbs.read
    get_data(@page)
    @count = @doc.root["count"]
    @pages = @count.to_i/100 + 1 # one extra page for checking up
  end

  def download_all
    while have_elements do
      download
      next_page
    end
    puts "Thats all."
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
        if @options[:kona]
          data_url = "http://konachan.com"
        else
          data_url = "http://danbooru.donmai.us"
        end
        data = open("#{data_url}/post/index.xml?limit=100&page=#{page_num}&tags=#{@tag}&login=#{@options[:user]}&password_hash=#{@options[:password]}").read
      rescue => ex
        puts "Error reading data — #{ex}"
        sleep 2
      end
    end
    @doc = Nokogiri::XML(data)
    @posts = @doc.xpath("//posts/post")
  end

  def write_tags(filename,tags)
    @bbs.puts "#{filename} - #{tags}"
  end

  def download
    @posts.each do |post|
      url = post["file_url"]
      md5 = post["md5"]
      filename = File.join(@tag,url.gsub("http://s3.amazonaws.com/danbooru/","").gsub("http://danbooru.donmai.us/data/","").gsub("http://kuro.hanyuu.net/image/#{md5}/","").gsub("http://konachan.com/image/#{md5}/","").gsub("http://kana.hanyuu.net/image/#{md5}/","").gsub("http://victorica.hanyuu.net/image/#{md5}/","").gsub("%20"," "))
      tags = post["tags"]
      if File.exist?(filename) && md5 == Digest::MD5.hexdigest(File.read(filename))
        puts "File exist - #{filename} (#{@num}/#{@count})"
      else
        puts "saving #{filename}... (#{@num}/#{@count})"
        if @options[:wget]
          `wget -nv -c '#{url}' -O '#{filename}'`
        elsif @options[:curl]
          `curl -C - --progress-bar -o '#{filename}' '#{url}'`
        else
          open(filename,"wb").write(open(url).read)
        end
        puts "saved!"
      end
      write_tags(filename,tags) if !@old_file.include?(filename)
      @num += 1
    end
  end

end

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: danbooru.rb [options] \"tags\""
  opts.on( '-k', '--konachan', 'Download from konachan.com instead of danbooru.donmai.us' ) do
    options[:kona] = true
  end
  opts.on( '-w', '--wget', 'Use wget for download' ) do
    options[:wget] = true
  end
  opts.on( '-c', '--curl', 'Use curl for download' ) do
    options[:curl] = true
  end
  opts.on( '-u', '--user USERNAME', 'Username' ) do |u|
    options[:user] = u
  end
  opts.on( '-p', '--password PASSWORD', 'Password' ) do |p|
    if options[:kona]
      password_string = "So-I-Heard-You-Like-Mupkids-?"
    else
      password_string = "choujin-steiner"
    end
    options[:password] = Digest::SHA1.hexdigest("#{password_string}--#{p}--")
  end
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

begin
  optparse.parse!
rescue => ex
  puts ex
end

if ARGV.length == 0 || ARGV[0].empty?
  puts optparse.help
else
  puts "tags are #{ARGV[0]}"
  d = Danbooru.new(ARGV[0], options)
  d.download_all
end
