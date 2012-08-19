# coding: utf-8

# Author: Ivan "Xeron" Larionov
# E-mail: xeron.oskom@gmail.com
# Homepage: http://xeron.13f.ru
# Version: 1.3

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
    password_string = case options[:board]
    when :konachan
      "So-I-Heard-You-Like-Mupkids-?"
    when :behoimi
      "meganekko-heaven"
    when :danbooru || :yandere
      "choujin-steiner"
    else
      nil
    end
    password_string = if password_string
      "#{password_string}--#{pass}--"
    else
      pass
    end
    options[:password] = Digest::SHA1.hexdigest(password_string)
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
  d = case options[:board]
  when :konachan
    Konachan.new(ARGV[0], options)
  when :e621
    E621.new(ARGV[0], options)
  when :behoimi
    Behoimi.new(ARGV[0], options)
  when :yandere
    Yandere.new(ARGV[0], options)
  else
    Danbooru.new(ARGV[0], options)
  end
  d.download_all
end
