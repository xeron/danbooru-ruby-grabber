# coding: utf-8

# Author: Ivan "Xeron" Larionov
# E-mail: xeron.oskom@gmail.com
# Homepage: http://blog.xeron.me
# Version: 2.4

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'booru'
require 'danbooru'
require 'konachan'
require 'e621'
require 'behoimi'
require 'yandere'

options = {}
options[:limits] = {}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: danbooru.rb [options] "tags"'

  opts.separator("\nTarget:")
  opts.on('-b', '--board BOARDNAME', 'Target board. Supported options: danbooru (default), konachan, e621, behoimi, yandere') do |board|
    options[:board] = board.to_sym
  end
  opts.on('-P', '--pool POOL_ID', 'Pool ID (tags will be ignored)') do |pool|
    if pool =~ /^[1-9][0-9]*/
      options[:pool] = pool.to_i
    else
      $stderr.puts "Wrong pool id: #{pool}. It should be a number greater than 0."
      exit 1
    end
  end

  opts.separator("\nStorage options:")
  opts.separator("    `-f tags` could miss some files due to filesystems' filename length limitation.")
  opts.on('-s', '--storage DIR', 'Storage mode (all images in one dir and symlinks in tagged dirs)') do |dir|
    options[:storage] = dir
  end
  opts.on('-f', '--filename PATTERN', 'Filename pattern. Supported options: id (default), md5, tags, url (old default)') do |filename|
    options[:filename] = filename.to_sym
  end

  opts.separator("\nAuthentication:")
  opts.separator("    This is optional, but recommended since some boards block access without authentication.")
  opts.on('-u', '--user USERNAME', 'Username') do |user|
    options[:user] = user
  end
  opts.on('-p', '--password PASSWORD', 'Password') do |pass|
    options[:password] = pass
  end

  opts.separator("\nTools:")
  opts.separator("    Ruby's file saver is used by default. You can change it using this options. `wget` or `curl` binaries should be available.")
  opts.on('-w', '--wget', 'Download using wget') do
    options[:downloader] = :wget
  end
  opts.on('-c', '--curl', 'Download using curl') do
    options[:downloader] = :curl
  end

  opts.separator("\nLimits:")
  opts.separator("    This option could be used multiple times with different limiters.")
  opts.on('-l', '--limit LIMITER', 'Limiters in the following format: limiter=number. Supported limiters: pages, posts, per_page') do |limiter|
    if limiter =~ /(pages|posts|per_page)=([1-9][0-9]*)/
      options[:limits][$1.to_sym] = $2.to_i
    else
      $stderr.puts "Wrong limiter: #{limiter}. It should be pages, posts or per_page and value should be a number greater than 0."
      exit 1
    end
  end

  opts.separator("\nHelp:")
  opts.on( '-h', '--help', 'Print a help message' ) do
    puts opts
    exit
  end
end

begin
  optparse.parse!
rescue => ex
  puts ex
end

if !options[:pool] && (ARGV.length == 0 || ARGV[0].empty?)
  puts optparse.help
else
  board = case options[:board]
  when :konachan
    Konachan.new(options)
  when :e621
    E621.new(options)
  when :behoimi
    Behoimi.new(options)
  when :yandere
    Yandere.new(options)
  else
    Danbooru.new(options)
  end
  if options[:pool]
    board.download_by_pool(options[:pool])
  else
    board.download_by_tags(ARGV[0])
  end
end
