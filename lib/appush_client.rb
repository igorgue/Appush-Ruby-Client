#appush_client.rb

require 'json'
require 'rest_client'

class AppushClient
  attr_accessor :user, :password, :protocol, :service_url

  def initialize(user, password, params={:service_url=>"https://appush.com/api"})
    @user = user
    @password = password

    # cleaning params[:service_url], removing tailing "/"
    params[:service_url] = clean_service_url(params[:service_url])

    # http://xkcd.com/208/
    @protocol = params[:service_url].match(/^https?:\/\//)[0] # match the protocol, http:// or https://
    @url = params[:service_url].sub(/^https?:\/\//, '') # removes the protocol form the service

    @service_url = "#{@protocol}#{@user}:#{@password}@#{@url}"
  end

  def to_s
    if push_secret.empty?
      return "Appush Client = #{@user}:#{@password}, Server = #{@service_url}"
    end

    "Appush Client = #{@user}:#{@password}, Server = #{@service_url}"
  end

  private

  def clean_service_url(service_url)
    while !service_url.match(/\/$/).nil?
      service_url = service_url.sub(/\/$/, '')
    end

    service_url
  end

  def get_hash(response)
    if response.nil?
      return {"status"=>204}
    end
     
    data = JSON.parse response
    data["status"] = response.code
         
    return data
  end
end

class RootUser < AppushClient
  # POST
  def create_application(name, env, dev_pem, prod_pem)
    url = "#{@service_url}/application"
    data = {:name=>name, :env=>env, :dev_pem=>dev_pem, :prod_pem=>prod_pem}.to_json

    get_hash RestClient.post url, data, :content_type=>"application/json", :accept=>"application/json"
  end

  # PUT
  # parameters are optional: :name, :env, :dev_pem, :prod_pem
  def modify_application(id, params={})
    url = "#{@service_url}/application/#{id}"
    data = Hash.new

    data[:name] = params[:name] if params[:name]
    data[:env] = params[:env] if params[:env]
    data[:dev_pem] = params[:dev_pem] if params[:dev_pem]
    data[:prod_pem] = params[:prod_pem] if params[:prod_pem]

    data = data.to_json
    get_hash RestClient.put url, data, :content_type=>"application/json", :accept=>"application/json"
  end

  # GET
  def list_applications()
    url = "#{@service_url}/application"

    get_hash RestClient.get url, :content_type=>"application/json", :accept=>"application/json"
  end

  # GET <id>
  def get_application(id)
    url = "#{@service_url}/application/#{id}"

    get_hash RestClient.get url, :content_type=>"application/json", :accept=>"application/json"
  end

  # DELETE <id>
  def delete_application(id)
    url = "#{@service_url}/application/#{id}"

    get_hash RestClient.delete url, :content_type=>"application/json", :accept=>"application/json"
  end

  # POST <id> send notification
  def send_notification(app_id, params={:tags=>[], :devices=>[], :exclude=>[], :alert=>"", :sound=>"", :badge=>0, :kv=>{}})
    url = "#{@service_url}/application/#{app_id}/notification"

    payload = {"aps"=>{"alert"=>params[:alert],
                       "sound"=>params[:sound],
                       "badge"=>params[:badge]}}.merge params[:kv]
    payload = {"payload"=>payload}
    data = {"tags"=>params[:tags],
            "devices"=>params[:devices],
            "exclude"=>params[:exclude]}.merge payload

    get_hash RestClient.post url, data, :content_type=>"application/json", :accept=>"application/json"
  end

  # GET get notification status
  def get_notification_status(app_id, notification_id)
    url = "#{@service_url}/application/#{app_id}/notification/#{notification_id}"
    
    get_hash RestClient.get url, :content_type=>"application/json", :accept=>"application/json"
  end

  # GET all the devices with a tag
  def get_devices_by_tag(app_id, tag)
    url = "#{@service_url}/application/#{app_id}/tag/#{tag}"

    get_hash RestClient.get url, :content_type=>"application/json", :accept=>"application/json"
  end
end

class Profile < AppushClient
  # GET device info
  def get_device(device_token)
    url = "#{@service_url}/device/#{device_token}"

    get_hash RestClient.get url, :content_type=>"application/json", :accept=>"application/json"
  end

  # PUT register a device with tags
  def register_device(tags=[])
    url = "#{@service_url}/device/#{device_token}"
    data = {:tags=>tags}.to_json

    get_hash RestClient.get url, data, :content_type=>"application/json", :accept=>"application/json"
  end

  # DELETE unregister device
  def unregister_device(device_token)
    url = "#{@service_url}/device/#{device_token}"

    get_hash RestClient.delete url, :content_type=>"application/json", :accept=>"application/json"
  end
end

class Application < AppushClient
  # POST
  def create_profile()
    url = "#{@service_url}/profile"
    
    get_hash RestClient.post url, :content_type=>"application/json", :accept=>"application/json"
  end
end
