require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "json"

class CarrotTop
  attr_reader :rabbitmq_api

  def initialize(options={})
    [:host, :port, :user, :password].each do |option|
      if options[option].nil?
        raise ArgumentError, "You must supply a RabbitMQ management API #{option}"
      end
    end
    protocol = options[:ssl] ? "https" : "http"
    credentials = "#{options[:user]}:#{options[:password]}"
    location = "#{options[:host]}:#{options[:port]}"
    @rabbitmq_api = "#{protocol}://#{credentials}@#{location}/api"
  end

  def query_api(options={})
    raise ArgumentError, "You must supply an API path" if options[:path].nil?
    fetch_uri(@rabbitmq_api + options[:path])
  end

  def method_missing(method, *args, &block)
    response = self.query_api(:path => "/#{method}")
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      Hash.new
    end
  end

  private

  def fetch_uri(uri, limit=5)
    raise ArgumentError, "HTTP redirect too deep" if limit == 0
    url = URI.parse(uri)
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(url.request_uri)
    request.add_field("content-type", "application/json")
    request.basic_auth(url.user, url.password)
    response = http.request(request)
    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      redirect_url = URI.parse(response["location"])
      redirect_url.user = url.user
      redirect_url.password = url.password
      fetch_uri(redirect_url.to_s, limit - 1)
    else
      response.error!
    end
  end

end
