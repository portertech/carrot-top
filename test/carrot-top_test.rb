$: << "#{File.dirname(__FILE__)}/../lib" unless $:.include?("#{File.dirname(__FILE__)}/../lib/")
require "rubygems" if RUBY_VERSION < "1.9.0"
gem "minitest"
require "minitest/autorun"
require "webmock/minitest"
require "carrot-top"

class TestCarrotTop < MiniTest::Unit::TestCase
  def setup
    stub_request(:get, /.*user:password@localhost:55672.*/).
      with(:headers => {'content-type'=>'application/json'}).
      to_return(:status => 200, :body => '{"status": "success"}', :headers => {'content-type'=>'application/json'})
    @rabbitmq_info = CarrotTop.new(:host => "localhost", :port => 55672, :user => "user", :password => "password")
  end

  def test_channels
    response = @rabbitmq_info.channels
    assert response["status"] == "success"
  end

  def test_queues
    response = @rabbitmq_info.queues
    assert response["status"] == "success"
  end
end
