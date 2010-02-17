# appush_client_spec.rb

require 'appush_client'
require 'webmock/rspec'

require 'json'

include WebMock
include Appush

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

  it "should modify an application" do
    result = ""
    id = "test"

    stub_request(:put, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}").to_return(:body=>result)

    @root_user.modify_application("test", :name=>"new name").to_s.should == result

    WebMock.should have_requested(:put, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}").once
  end

  it "should list all applications" do
    result = "[\"app1\", \"app2\"]"

    stub_request(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application").to_return(:body=>result)

    @root_user.list_applications.to_s.should == result

    WebMock.should have_requested(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application").once
  end

  it "should get an application" do
    result = "{\"name\":\"My New Application\", \"application_token\": \"EVtmyITWMKzDRtawXxubVmfIYWU\", \"application_secret\": \"e52c6cbd232e2111671953d320ff80a2\", \"status\":\"dev\",\"dev_pem\":\"Bag Attributes\", \"active_devices\":0}\""
    id = "test"

    stub_request(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}").to_return(:body=>result)

    @root_user.get_application(id).to_s.should == result

    WebMock.should have_requested(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}").once
  end

  it "should get an application icon" do
    result = File.read("#{File.dirname(__FILE__)}/no-icon.png")
    id = "test"

    stub_request(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}/icon").to_return(:body=>result)

    @root_user.get_application_icon(id).to_s.should == result

    WebMock.should have_requested(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}/icon").once
  end

  it "should save an application icon" do
    icon = File.read("#{File.dirname(__FILE__)}/no-icon.png")
    id = "test"

    stub_request(:put, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}/icon").with(:body=>icon, :headers=>{"Content-Type"=>"image/png"}).to_return(:body=>"")

    @root_user.save_application_icon(id, icon).to_s.should == ""

    WebMock.should have_requested(:put, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}/icon").once
  end

  it "should delete an application" do
    id = "test"

    stub_request(:delete, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}").to_return(:body=>"")

    @root_user.delete_application(id).to_s.should == ""

    WebMock.should have_requested(:delete, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}").once
  end

  it "should send a notification" do
    id = "test"

    params={:tags=>["one", "two", "three"],
            :devices=>["lol", "waa"],
            :exclude=>["do", "not", "exclude", "me"],
            :alert=>"w00t!",
            :sound=>"cat.ogg",
            :badge=>1,
            :kv=>{:go=>"crazy"}}

    stub_request(:post, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}/notification").with(:body=>"{\"devices\":[\"lol\",\"waa\"],\"payload\":{\"go\":\"crazy\",\"aps\":{\"badge\":1,\"sound\":\"cat.ogg\",\"alert\":\"w00t!\"}},\"exclude\":[\"do\",\"not\",\"exclude\",\"me\"],\"tags\":[\"one\",\"two\",\"three\"]}", :headers=>{"Content-Type"=>"application/json"}).to_return(:body=>"")

    @root_user.send_notification(id, params).to_s.should == ""

    WebMock.should have_requested(:post, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{id}/notification").once
  end

  it "should get an notification status" do
    app_id = "test_app"
    notification_id = "test_notification"

    stub_request(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{app_id}/notification/#{notification_id}").to_return(:body=>"")

    @root_user.get_notification_status(app_id, notification_id).to_s.should == ""

    WebMock.should have_requested(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{app_id}/notification/#{notification_id}").once
  end

  it "should get all devices by tag" do
    app_id = "test"
    tag = "waa"

    stub_request(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{app_id}/tag/#{tag}").to_return(:body=>"")

    @root_user.get_devices_by_tag(app_id, tag).to_s.should == ""

    WebMock.should have_requested(:get, "https://#{@root_key}:#{@root_secret}@appush.com/api/application/#{app_id}/tag/#{tag}").once
  end

  it "should get a device information" do
    dev_token = "test_dev"

    stub_request(:get, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").to_return(:body=>"")

    @profile.get_device(dev_token).to_s.should == ""

    WebMock.should have_requested(:get, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").once
  end

  it "should register a device with tags" do
    dev_token = "test_dev"
    tags = ["foo", "bar"]

    stub_request(:put, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").with(:body=>{:tags=>tags}.to_json, :headers=>{"Content-Type"=>"application/json"}).to_return(:body=>"")

    @profile.register_device(dev_token, tags).to_s.should == ""

    WebMock.should have_requested(:put, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").once
  end

  it "should register a device without tags" do
    dev_token = "test_dev"
    tags = []

    stub_request(:put, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").with(:body=>{:tags=>tags}.to_json, :headers=>{"Content-Type"=>"application/json"}).to_return(:body=>"")

    @profile.register_device(dev_token, tags).to_s.should == ""

    WebMock.should have_requested(:put, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").once
  end

  it "should unregister a device" do
    dev_token = "test_dev"

    stub_request(:delete, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").to_return(:body=>"")

    @profile.unregister_device(dev_token).to_s.should == ""

    WebMock.should have_requested(:delete, "https://#{@profile_key}:#{@profile_secret}@appush.com/api/device/#{dev_token}").once
  end

  it "should create a profile" do
    result = "[\"x\", \"y\"]"

    stub_request(:post, "https://#{@app_key}:#{@app_secret}@appush.com/api/profile").with(:headers=>{"Content-Type"=>"application/json"}).to_return(:body=>result)

    @application.create_profile.to_s.should == result

    WebMock.should have_requested(:post, "https://#{@app_key}:#{@app_secret}@appush.com/api/profile").once
  end
end
