# appush_client_spec.rb

require 'appush_client'
require 'webmock/rspec'

include WebMock

describe "Using Appush client API" do
  before(:each) do
    # I used test keys and tokens, but tested them to work
    @root_key = "09a539a84e32ddbce7c6bcdcedba78f4"
    @root_secret = "e77694945eff115f4b0cc6d0bcf800ec"
    @app_key = "38KaiutatmjKWPsbksVco1YeQeE"
    @app_secret = "5ZulDkmNY230rRyx3v6CaJfkAhP"
    @profile_key = "GkYwZ5xTV8PXJJZksQDV3POKMCp"
    @profile_secret = "TqRrqWfnW0Zp4jsxOEQQR6iCcLH"
    @service_url = "https://appush.com/api"

    # we initialize every object on every test
    @root_user = RootUser.new @root_key, @root_secret, :service_url=>@service_url
    @application = Application.new @app_key, @app_secret, :service_url=>@service_url
    @profile = Profile.new @profile_key, @profile_secret, :service_url=>@service_url
  end

  it "should not be null" do
    @root_user.should_not be nil
    @root_user.to_s.should == "Server = https://09a539a84e32ddbce7c6bcdcedba78f4:e77694945eff115f4b0cc6d0bcf800ec@appush.com/api"

    @application.should_not be nil
    @application.to_s.should == "Server = https://38KaiutatmjKWPsbksVco1YeQeE:5ZulDkmNY230rRyx3v6CaJfkAhP@appush.com/api"

    @profile.should_not be nil
    @profile.to_s.should == "Server = https://GkYwZ5xTV8PXJJZksQDV3POKMCp:TqRrqWfnW0Zp4jsxOEQQR6iCcLH@appush.com/api"
  end

  it "should create an application" do
    result = "{\"id\":\"YZgzHWpxdt4emUAYTptovTcfYdW\"}"

    stub_request(:post, "https://#{@root_key}:#{@root_secret}@appush.com/api/application").to_return(:body=>result)

    @root_user.create_application("test").to_s.should == result

    WebMock.should have_requested(:post, "https://#{@root_key}:#{@root_secret}@appush.com/api/application").once
  end

  #it "should modify an application" do
    #result_code = 204

    #stub_request(:put, "https://#{@root_key}:#{
  #end
  
  #it "should get device information" do
    #result = {"tags"=>["foo", "waa"], "status"=> 200}

    #stub_request(:get, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").to_return(:body=>result.to_json)

    #@client.get_device("test_device").should == result

    #WebMock.should have_requested(:get, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").once
  #end

  #it "should register devices" do
    #result = {"status"=>204}

    #stub_request(:put, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device2").to_return(:body=>result.to_json, :status=>204)

    #@client.register_device("test_device2").should == result

    #WebMock.should have_requested(:put, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device2").once
  #end

  #it "should unregister devices" do
    #result = {"status"=>204}

    #stub_request(:delete, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").to_return(:body=>result.to_json, :status=>204)

    #@client.unregister_device("test_device").should == result

    #WebMock.should have_requested(:delete, "#{@client.protocol}#{@client.app_key}:#{@client.app_secret}@#{@client.service_url}/device/test_device").once
  #end

  #it "should get devices using a tag" do
    #result = {"devices"=>["test_device"],"status"=>200}

    #stub_request(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/tag/waa").to_return(:body=>result.to_json, :status=>200)

    #@client.get_devices_by_tag("waa").should == result

    #WebMock.should have_requested(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/tag/waa").once
  #end

  #it "should send notifications" do
    #result = {"status"=>201}
    #tags = ["foo", "waa"]
    #devices = ["test_device"]
    #exclude = ["invalid_device"]
    #alert = "hello"
    #sound = "meow.aiff"
    #badge = 1
    #kv = {"spam"=>"foo"}

    #stub_request(:post, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification").to_return(:status=>201, :body=>result.to_json)

    #@client.send_notification(:tags=>tags, :devices=>devices, :exclude=>exclude, :alert=>alert, :sound=>sound, :badge=>badge, :kv=>kv).should == {"status"=>201}

    #WebMock.should have_requested(:post, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification").once
  #end

  #it "should get notifications statuses" do
    #result = {"devices"=>["test_device"], "completed"=>0, "payload"=>{"aps"=>{"badge"=>1, "sound"=>"meow.aiff", "alert"=>"Hello World"}, "spam"=>"eggs"}, "delivered"=>[], "tags"=>["foo", "bar", "baz"], "status"=>200}

    #stub_request(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification/id_notify").to_return(:body=>result.to_json)

    #@client.get_notification_status("id_notify").should == result

    #WebMock.should have_requested(:get, "#{@client.protocol}#{@client.app_key}:#{@client.push_secret}@#{@client.service_url}/notification/id_notify").once
  #end
end
