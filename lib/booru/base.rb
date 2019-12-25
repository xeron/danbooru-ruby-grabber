require 'rubygems'
require 'json'
require 'nokogiri'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'fileutils'
require 'optparse'
require 'digest/sha1'
require 'digest/md5'

class Booru
  API_BASE_URL = 'http://example.com'
  PASSWORD_SALT = nil
  OLD_API = false
  USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0'

  attr_accessor :options

  def initialize(opts)
    self.options = opts
    if options[:base_path]
      FileUtils.mkdir_p options[:base_path]
      Dir.chdir options[:base_path]
    end
    FileUtils.mkdir_p options[:storage] if options[:storage]
    @referer = self.class::API_BASE_URL
    options[:limits][:per_page] ||= 100
  end

  private

  def do_request(url, params = {}, method = :get, data = nil, format = :json, url_prepared = false, limit = 10)
    full_params = params.merge(
      login: options[:user],
      password_hash: get_password_hash(options[:password], self.class::PASSWORD_SALT)
    )
    full_url =
      if url_prepared
        url
      else
        prepare_url(url, full_params)
      end
    uri = URI.join(self.class::API_BASE_URL, full_url)
    http_params = {
      'User-Agent' => USER_AGENT,
      'Referer' => @referer
    }

    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    case method
    when :get
      request = Net::HTTP::Get.new(uri.request_uri, http_params)
    when :post
      request = Net::HTTP::Post.new(uri.request_uri, http_params)
      request.content_type = 'application/x-www-form-urlencoded'
      request.body = "data=#{data}" if data
    end

    response = http.request(request)

    case response
    when Net::HTTPSuccess then parse_response(response, format)
    when Net::HTTPRedirection
      if limit.positive?
        do_request(response['location'], params, method, data, format, true, limit - 1)
      else
        warn 'Too many redirects.'
        exit 1
      end
    else response.value
    end
  end

  def prepare_url(url, full_params)
    [
      url,
      full_params.map { |key, val| "#{key}=#{CGI.escape(val.to_s)}" }.join('&')
    ].join('?').gsub('%2B', '+')
  end

  def get_password_hash(password, salt)
    if salt
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    else
      options[:password]
    end
  end

  def parse_response(response, format)
    response_ok = true

    case format
    when :json
      response_hash = JSON.parse(response.body)
      response_ok = false if response_hash.include?('success') && response_hash['success'] == false
    when :xml
      response_hash = Nokogiri::XML(response.body)
      response_ok = false if response_hash.root['success'] == 'false'
    else
      raise 'Unknown format'
    end

    return response_hash if response_ok

    raise response_hash
  end

  def only_new_api
    return unless self.class::OLD_API

    warn 'Supported only with a new API (danbooru.donmai.us)'
    exit 1
  end

  def only_old_api
    return if self.class::OLD_API

    warn 'Supported only with an old API (not danbooru.donmai.us)'
    exit 1
  end

  def sanitize_filename(filename)
    filename.gsub(%r{[\?\*\/\\\:]}, '_')
  end
end
