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

  API_BASE_URL = "http://example.com"
  PASSWORD_SALT = "choujin-steiner"
  OLD_API = false
  USER_AGENT = "Mozilla/5.0"

  attr_accessor :options

  def initialize(opts)
    self.options = opts
    FileUtils.mkdir_p options[:storage] if options[:storage]
    @referer = self.class::API_BASE_URL
    options[:limits][:per_page] ||= 100
  end

  private

  def do_request(url, params = {}, method = :get, data = nil, format = :json, url_prepared = false, limit = 10)
    full_params = params.merge({
      :login => options[:user],
      :password_hash => get_password_hash(options[:password], self.class::PASSWORD_SALT)
    })
    full_url = url_prepared ? url : url + "?" + full_params.map { |key, val| "#{key}=#{val}" }.join("&")
    uri = URI.join(self.class::API_BASE_URL, URI.escape(full_url))
    http_params = {
      "User-Agent" => USER_AGENT,
      "Referer" => @referer
    }

    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    case method
    when :get
      request = Net::HTTP::Get.new(uri.request_uri, http_params)
    when :post
      request = Net::HTTP::Post.new(uri.request_uri, http_params)
      request.content_type = "application/x-www-form-urlencoded"
      request.body = "data=#{data}" if data
    end

    response = http.request(request)

    case response
    when Net::HTTPSuccess then parse_response(response, format)
    when Net::HTTPRedirection
      if limit > 0
        do_request(response["location"], params, method, data, format, true, limit - 1)
      else
        $stderr.puts "Too much redirects."
        exit 1
      end
    else return response.value
    end
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
      response_body_hash = JSON.parse(response.body)
      if response_body_hash.include?("success") && response_body_hash["success"] == false
        response_ok = false
      end
    when :xml
      response_body_hash = Nokogiri::XML(response.body)
      if response_body_hash.root["success"] == "false"
        response_ok = false
      end
    else
      raise "Unknown format"
    end

    if response_ok
      return response_body_hash
    else
      raise response_body_hash
    end
  end

  def only_new_api
    if self.class::OLD_API
      $stderr.puts "Supported only with a new API (danbooru.donmai.us)"
      exit 1
    end
  end

  def only_old_api
    unless self.class::OLD_API
      $stderr.puts "Supported only with an old API (not danbooru.donmai.us)"
      exit 1
    end
  end

  def sanitize_filename(filename)
    filename.gsub(/[\?\*\/\\]/, "_")
  end

end
