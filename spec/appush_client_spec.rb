# appush_client_spec.rb

require 'appush_client'
require 'webmock/rspec'

include WebMock

describe "Using Appush client API" do
  before(:each) do
    @app_key = "I6ieYiJtbH3YPriyR3AK3VZtgSP"
    @app_secret = "48907eb5efbffe9ee23e62e2b9273929"
    @push_secret = "72781d3c6d508699e8f3918de6dceb25"
    @service_url = "http://appush.com/api"

    @client = AppushClient.new @app_key,
                               @app_secret,
                               :push_secret=>@push_secret,
                               :service_url=>@service_url
  end

  it "should not be null" do
    @client.should_not be nil
    @client.to_s.should == "Appush Client = I6ieYiJtbH3YPriyR3AK3VZtgSP:48907eb5efbffe9ee23e62e2b9273929, Push Secret = 72781d3c6d508699e8f3918de6dceb25, Server = appush.com/api"
    @client.protocol.should == "http://"
  end
  
  it "should get device information" do
    result = {"tags"=>["foo", "waa"], "status"=> 200}

    stub_request(:get, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").to_return(:body=>result.to_json)

    @client.get_device("test_device").should == result

    WebMock.should have_requested(:get, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").once
  end

  it "should register devices" do
    result = {"status"=>204}

    stub_request(:put, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device2").to_return(:body=>result.to_json, :status=>204)

    @client.register_device("test_device2").should == result

    WebMock.should have_requested(:put, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device2").once
  end

  it "should unregister devices" do
    result = {"status"=>204}

    stub_request(:delete, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").to_return(:body=>result.to_json, :status=>204)

    @client.unregister_device("test_device").should == result

    WebMock.should have_requested(:delete, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").once
  end

  it "should get devices using a tag" do
    result = {"devices"=>["test_device"],"status"=>200}

    stub_request(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/tag/waa").to_return(:body=>result.to_json, :status=>200)

    @client.get_devices_by_tag("waa").should == result

    WebMock.should have_requested(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/tag/waa").once
  end

  it "should send notifications" do
    result = {"status"=>201}
    tags = ["foo", "waa"]
    devices = ["test_device"]
    exclude = ["invalid_device"]
    alert = "hello"
    sound = "meow.aiff"
    badge = 1
    kv = {"spam"=>"foo"}

    stub_request(:post, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification").to_return(:status=>201, :body=>result.to_json)

    @client.send_notification(:tags=>tags, :devices=>devices, :exclude=>exclude, :alert=>alert, :sound=>sound, :badge=>badge, :kv=>kv).should == {"status"=>201}

    WebMock.should have_requested(:post, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification").once
  end

  it "should get notifications statuses" do
    result = {"devices"=>["test_device"], "completed"=>0, "payload"=>{"aps"=>{"badge"=>1, "sound"=>"meow.aiff", "alert"=>"Hello World"}, "spam"=>"eggs"}, "delivered"=>[], "tags"=>["foo", "bar", "baz"], "status"=>200}

    stub_request(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification/id_notify").to_return(:body=>result.to_json)

    @client.get_notification_status("id_notify").should == result

    WebMock.should have_requested(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification/id_notify").once
  end
end
