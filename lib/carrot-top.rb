require "rubygems" if RUBY_VERSION < "1.9.0"
require "net/http"
require "uri"
require "json"

class CarrotTop
  def initialize(options={})
    [:host, :port, :user, :password].each do |option|
      raise "You must supply a RabbitMQ management #{option}" if options[option].nil?
    end
    @ssl = options[:ssl] || false
    protocol = @ssl ? "https" : "http"
    @rabbitmq_api = "#{protocol}://#{host}:#{port}/api"
    @user = options[:user]
    @password = options[:password]
  end

  def query_api(options={})
    raise "You must supply an API path" if options[:path].nil?
    URI.parse(@rabbitmq_api + options[:path])
    http = Net::HTTP.new(uri.host, uri.port)
    if options[:ssl] == true
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field("content-type", "application/json")
    request.basic_auth(@user, @password)
    http.request(request)
  end

  def self.method_missing(method, *args, &block)
    response = self.query_api(:path => "/#{method}")
    JSON.parse(response.body)
  end
end
