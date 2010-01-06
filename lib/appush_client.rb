#appush_client.rb

require 'json'
require 'rest_client'

class AppushClient
  attr_accessor :app_key, :app_secret, :push_secret, :protocol, :service_url

  def initialize(app_key, app_secret, params={:push_secret=>"", :service_url=>"https://appush.com/api"})
    @app_key = app_key
    @app_secret = app_secret
    @push_secret = params[:push_secret]

    # cleaning params[:service_url], removing tailing "/"
    params[:service_url] = clean_service_url params[:service_url]

    # http://xkcd.com/208/
    @protocol = params[:service_url].match(/^https?:\/\//)[0] # match the protocol, http:// or https://
    @service_url = params[:service_url].sub(/^https?:\/\//, '') # removes the protocol form the service
  end

  def to_s
    if push_secret.empty?
      return "Appush Client = #{@app_key}:#{@app_secret}, Server = #{@service_url}"
    end

    "Appush Client = #{@app_key}:#{@app_secret}, Push Secret = #{@push_secret}, Server = #{@service_url}"
  end

  def get_hash(response)
    if response.nil?
      return {"status"=>204}
    end

    data = JSON.parse response
    data["status"] = response.code

    return data
  end

  def get_device(device_token)
    begin
      response = RestClient.get "#{@protocol}#{@app_key}:#{@app_secret}@#{@service_url}/device/#{device_token}",
                                :content_type=>"application/json",
                                :accept=>"application/json"
      return get_hash response
    rescue
      return {"status"=>404}
    end
  end

  def register_device(device_token, tags=[])
    begin
      data = {"tags" => tags}.to_json
      response = RestClient.put "#{@protocol}#{@app_key}:#{@app_secret}@#{@service_url}/device/#{device_token}", data,
                                :content_type=>"application/json",
                                :accept=>"application/json"
      return get_hash response
    rescue
      return {"status"=>404}
    end
  end

  def unregister_device(device_token)
    begin
      response = RestClient.delete "#{@protocol}#{@app_key}:#{@app_secret}@#{@service_url}/device/#{device_token}",
                                   :content_type=>"application/json",
                                   :accept=>"application/json"
      return get_hash response
    rescue
      return {"status"=>404}
    end
  end

  def get_devices_by_tag(tag)
    begin
      response = RestClient.get "#{@protocol}#{@app_key}:#{@push_secret}@#{@service_url}/tag/#{tag}",
                                :content_type=>"application/json",
                                :accept=>"application/json"
      return get_hash response
    rescue
      return {"status"=>404}
    end
  end

  def send_notification(params={:tags=>[], :devices=>[], :exclude=>[], :alert=>"", :sound=>"", :badge=>0, :kv=>{}})
    begin
      payload = {"aps"=>{"alert"=>params[:alert],
                         "sound"=>params[:sound],
                         "badge"=>params[:badge]}}.merge params[:kv]
      payload = {"payload"=>payload}
      data = {"tags"=>params[:tags],
              "devices"=>params[:devices],
              "exclude"=>params[:exclude]}.merge payload

      response = RestClient.post "#{@protocol}#{@app_key}:#{@push_secret}@#{@service_url}/notification", data,
                                 :content_type=>"application/json",
                                 :accept=>"application/json"
      return get_hash response
    rescue
      return {"status"=>400}
    end
  end

  def get_notification_status(notification_id)
    begin
      response = RestClient.get "#{@protocol}#{@app_key}:#{@push_secret}@#{@service_url}/notification/#{notification_id}",
                                :content_type=>"application/json",
                                :accept=>"application/json"
      return get_hash response
    rescue
      return {"status"=>404}
    end
  end

  private

  def clean_service_url(service_url)
    while !service_url.match(/\/$/).nil?
      service_url = service_url.sub(/\/$/, '')
    end

    service_url
  end
end
