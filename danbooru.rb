# Author: Ivan "Xeron" Larionov
# E-mail: xeron.oskom@gmail.com
# Homepage: http://blog.xeron.me
# Version: 2.7

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'booru'
require 'danbooru'
require 'testbooru'
require 'konachan'
require 'behoimi'
require 'yandere'

options = {}
options[:limits] = {}
optparse = OptionParser.new do |opts| # rubocop:disable Metrics/BlockLength
  opts.banner = 'Usage: danbooru.rb [options] "tags"'

  opts.separator("\nTarget:")
  opts.on(
    '-b', '--board BOARDNAME',
    'Target board. Supported options: danbooru (default), konachan, behoimi, yandere'
  ) do |board|
    options[:board] = board.to_sym
  end
  opts.on(
    '-P', '--pool POOL_ID',
    'Pool ID (tags will be ignored)'
  ) do |pool|
    if /^[1-9][0-9]*/.match?(pool)
      options[:pool] = pool.to_i
    else
      warn "Wrong pool id: #{pool}. It should be a number greater than 0."
      exit 1
    end
  end

  opts.separator("\nStorage options:")
  opts.on(
    '-s', '--storage DIR',
    'Storage mode (all images in one dir and symlinks in tagged dirs)'
  ) do |dir|
    options[:storage] = dir
  end
  opts.on(
    '-d', '--directory BASE_DIR',
    'Base directory to save images. By default it uses the same location as script'
  ) do |base_path|
    options[:base_path] = base_path
  end
  opts.on(
    '-f', '--filename PATTERN',
    'Filename pattern. Supported options: id (default), md5, tags, url (old default)'
  ) do |filename|
    options[:filename] = filename.to_sym
  end
  opts.separator("\tNote: `-f tags` could miss some files due to filesystems' filename length limitation.")

  opts.separator("\nAuthentication:")
  opts.separator('    This is optional, but recommended since some boards block access without authentication.')
  opts.on('-u', '--user USERNAME', 'Username') do |user|
    options[:user] = user
  end
  opts.on('-p', '--password PASSWORD', 'Password') do |pass|
    options[:password] = pass
  end

  opts.separator("\nTools:")
  opts.separator(
    "    Ruby's file saver is used by default. You can change it using this options." \
    ' `wget` or `curl` binaries should be available.'
  )
  opts.on('-w', '--wget', 'Download using wget') do
    options[:downloader] = :wget
  end
  opts.on('-c', '--curl', 'Download using curl') do
    options[:downloader] = :curl
  end

  opts.separator("\nLimits:")
  opts.separator('    This option could be used multiple times with different limiters.')
  opts.on(
    '-l', '--limit LIMITER',
    'Limiters in the following format: limiter=number. Supported limiters: pages, posts, per_page'
  ) do |limiter|
    if limiter =~ /(pages|posts|per_page)=([1-9][0-9]*)/
      options[:limits][Regexp.last_match[1].to_sym] = Regexp.last_match[2].to_i
    else
      warn \
        "Wrong limiter: #{limiter}. It should be pages, posts or per_page and value should be a number greater than 0."
      exit 1
    end
  end

  opts.separator("\nHelp:")
  opts.on('-h', '--help', 'Print a help message') do
    puts opts
    exit
  end
end

begin
  optparse.parse!
rescue StandardError => e
  puts e
end

if !options[:pool] && (ARGV.length.zero? || ARGV[0].empty?)
  puts optparse.help
else
  board =
    case options[:board]
    when :konachan
      Konachan.new(options)
    when :behoimi
      Behoimi.new(options)
    when :yandere
      Yandere.new(options)
    when :testbooru
      Testbooru.new(options)
    else
      Danbooru.new(options)
    end

  if options[:pool]
    board.download_by_pool(options[:pool])
  else
    board.download_by_tags(ARGV[0])
  end
end
