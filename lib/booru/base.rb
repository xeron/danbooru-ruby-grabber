require 'rubygems'
require 'json'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'cgi'
require 'fileutils'
require 'optparse'
require 'digest/sha1'
require 'digest/md5'

class Booru

  USER_AGENT = "Mozilla/5.0"

  attr_accessor :options, :tags, :bbs_path, :api_base_url

  def initialize(tag, opts)
    self.options = opts
    self.tags = options[:pool] || tag.gsub(" ", "+")
    FileUtils.mkdir_p tags
    self.bbs_path = if options[:storage]
      FileUtils.mkdir_p options[:storage]
      File.join(options[:storage], "files.bbs")
    else
      File.join(tags, "files.bbs")
    end
    @bbs = File.new(bbs_path, "a+")
    @old_bbs = @bbs.read
  end

  private

  def do_request(url, params = {}, method = :get, data = nil)
    params.merge!({:login => options[:user], :password_hash => options[:password]})
    full_url = url + "?" + params.map{|key, val| "#{key}=#{val}"}.join("&")
    uri = URI.join(api_base_url, URI.escape(full_url))

    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http_params = {
      "Accept" => "application/json",
      "User-Agent" => USER_AGENT,
      "Referer" => api_base_url
    }
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
    response_body_hash = JSON.parse(response.body)

    if response_body_hash.include?("success") && response_body_hash["success"] = false
      raise response_body_hash
    else
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        return response_body_hash
      else
        return response.value
      end
    end
  end

end
