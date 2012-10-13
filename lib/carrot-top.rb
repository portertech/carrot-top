require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "json"

class CarrotTop
  attr_reader :rabbitmq_api

  def initialize(options={})
    [:host, :port, :user, :password].each do |option|
      raise "You must supply a RabbitMQ management API #{option}" if options[option].nil?
    end
    protocol = options[:ssl] ? "https" : "http"
    credentials = "#{options[:user]}:#{options[:password]}"
    location = "#{options[:host]}:#{options[:port]}"
    @rabbitmq_api = "#{protocol}://#{credentials}@#{location}/api"
  end

  def query_api(options={})
    raise "You must supply an API path" if options[:path].nil?
    uri = URI.parse(@rabbitmq_api + options[:path])
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field("content-type", "application/json")
    request.basic_auth(uri.user, uri.password)
    http.request(request)
  end

  def method_missing(method, *args, &block)
    response = self.query_api(:path => "/#{method}")
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      Hash.new
    end
  end
end
