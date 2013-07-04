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

  attr_accessor :options, :tags

  def initialize(tag, opts)
    self.options = opts
    self.tags = options[:pool] || tag.gsub(" ", "+")
    FileUtils.mkdir_p tags
    bbs_path = if options[:storage]
      FileUtils.mkdir_p options[:storage]
      File.join(options[:storage], "files.bbs")
    else
      File.join(tags, "files.bbs")
    end
    @bbs = File.new(bbs_path, "a+")
    @old_bbs = @bbs.read
    @referer = self.class::API_BASE_URL
  end

  private

  def do_request(url, params = {}, method = :get, data = nil, format = :json)
    params.merge!({
      :login => options[:user],
      :password_hash => get_password_hash(options[:password], self.class::PASSWORD_SALT)
    })
    full_url = url + "?" + params.map{|key, val| "#{key}=#{val}"}.join("&")
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

    request.basic_auth(@user, @password)
    response = http.request(request)

    check_response(response, format)
  end

  def get_password_hash(password, salt)
    if salt
      Digest::SHA1.hexdigest("#{salt}--#{password}--")
    else
      options[:password]
    end
  end

  def check_response(response, format)
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
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
    else
      return response.value
    end
  end

end