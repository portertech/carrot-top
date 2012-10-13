require "minitest/spec"
require "minitest/autorun"
require "webmock/minitest"

require File.join(File.dirname(__FILE__), "..", "lib", "carrot-top")

describe CarrotTop do
  before do
    @options = {
      :host => "localhost",
      :port => 55672,
      :user => "user",
      :password => "password"
    }
    @body = {"foo" => "bar"}
    api_uri = "#{@options[:user]}:#{@options[:password]}@#{@options[:host]}:#{@options[:port]}/api"
    stub_request(:get, /.*#{api_uri}.*/).
      with(:headers => {"content-type" => "application/json"}).
      to_return(:status => 200, :body => @body.to_json, :headers => {"content-type" => "application/json"})
  end

  it "can query the rabbitmq management api" do
    carrot_top = CarrotTop.new(@options)
    response = carrot_top.query_api(:path => "/foo")
    response.code.must_equal("200")
    response.body.must_equal(@body.to_json)
  end

  it "can query the rabbitmq management using ssl" do
    carrot_top = CarrotTop.new(@options.merge(:ssl => true))
    carrot_top.rabbitmq_api.must_match(/^https/)
    response = carrot_top.query_api(:path => "/foo")
    response.code.must_equal("200")
    response.body.must_equal(@body.to_json)
  end

  it "can query the rabbitmq management api with method missing" do
    carrot_top = CarrotTop.new(@options)
    body = carrot_top.foo
    body.must_equal(@body)
  end

  it "must be provided mandatory options" do
    options = @options
    options.delete(:port)
    lambda {
      CarrotTop.new(options)
    }.must_raise(RuntimeError)
  end
end
