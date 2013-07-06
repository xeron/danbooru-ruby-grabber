# coding: utf-8

# Author: Ivan "Xeron" Larionov
# E-mail: xeron.oskom@gmail.com
# Homepage: http://xeron.13f.ru
# Version: 2.0

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'booru'
require 'danbooru'
require 'konachan'
require 'e621'
require 'behoimi'
require 'yandere'

options = {}
options[:board] = :danbooru
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: danbooru.rb [options] \"tags\""
  opts.on('-b', '--board BOARDNAME', 'Where from to download. Supported options: danbooru (default), konachan, e621, behoimi, yandere') do |board|
    options[:board] = board.to_sym
  end
  opts.on('-P', '--pool POOLID', 'Pool ID (tags will be ignored)') do |pool|
    options[:pool] = pool
  end
  opts.on('-w', '--wget', 'Use wget for download') do
    options[:downloader] = :wget
  end
  opts.on('-c', '--curl', 'Use curl for download') do
    options[:downloader] = :curl
  end
  opts.on('-s', '--storage DIR', 'Storage mode (all images in one dir and symlinks in tagged dirs)') do |dir|
    options[:storage] = dir
  end
  opts.on('-u', '--user USERNAME', 'Username') do |user|
    options[:user] = user
  end
  opts.on('-p', '--password PASSWORD', 'Password') do |pass|
    options[:password] = pass
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
