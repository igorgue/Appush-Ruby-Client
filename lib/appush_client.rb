require 'net/http'
require 'json'

module AppushClient
  class AppushClient
    attr_accessor :user, :password, :protocol, :service_url

    def initialize(user, password, params={})
      params = {:service_url=>"https://appush.com/api"}.merge params
      @user = user
      @password = password

      u = URI.parse(params[:service_url])
      @http = Net::HTTP.new(u.host, u.port)
      @http.use_ssl = true if u.scheme == 'https'
      @path = u.path
      @service_url = "#{u.scheme}://#@user:#@password@#{u.host}#{u.path}"
    end

    def post(path, body=nil, options={})
      res = request(:post, path, body, options)
      return res.body
    end

    def put(path, body=nil, options={})
      res = request(:put, path, body, options)
      return res.body
    end

    def delete(path, options={})
      res = request(:delete, path, nil, options)
      return res.body
    end

    def get(path, options={})
      res = request(:get, path, nil, options)
      return res.body
    end

    def request(method, path, body, options)
      options = {:content_type=>'application/json'}.merge(options)
      req = case method
      when :get
        Net::HTTP::Get.new("#@path#{path}")
      when :post
        Net::HTTP::Post.new("#@path#{path}")
      when :put
        Net::HTTP::Put.new("#@path#{path}")
      when :delete
        Net::HTTP::Delete.new("#@path#{path}")
      end
      req.basic_auth @user, @password
      req.content_type = options[:content_type]
      req.body = body
      res = @http.request(req)
      check_for_error(res)
    end

    def check_for_error(res)
      case res.code
      when /^(4|5)/
        raise AppushClient.const_set(res.class.to_s.split('::').last, Class.new(StandardError))
      else
        return res
      end
    end

    def to_s
      "Server = #{@service_url}"
    end
  end

  class RootUser < AppushClient
    # POST
    def create_application(name, env="dev", dev_pem="", prod_pem="")
      data = {:name=>name, :env=>env, :dev_pem=>dev_pem, :prod_pem=>prod_pem}.to_json
      post "/application", data
    end

    # PUT
    # parameters are optional: :name, :env, :dev_pem, :prod_pem
    def modify_application(id, params={})
      data = Hash.new
      data[:name] = params[:name] if params[:name]
      data[:env] = params[:env] if params[:env]
      data[:dev_pem] = params[:dev_pem] if params[:dev_pem]
      data[:prod_pem] = params[:prod_pem] if params[:prod_pem]

      data = data.to_json
      put "/application/#{id}", data
    end

    # GET
    def list_applications()
      get "/application"
    end

    # GET <id>
    def get_application(id)
      get "/application/#{id}"
    end

    # GET application/<id>/icon
    def get_application_icon(id)
      get "/application/#{id}/icon", :content_type=>"image/png"
    end

    # PUT application/<id>/icon
    def save_application_icon(app_id, icon)
      put "/application/#{app_id}/icon", icon, :content_type=>"image/png"
    end

    # DELETE <id>
    def delete_application(id)
      delete "/application/#{id}"
    end

    # POST <id> send notification
    def send_notification(app_id, params={})
      params = {:tags=>[], :devices=>[], :exclude=>[], :alert=>"", :sound=>"", :badge=>0, :kv=>[]}.merge params

      payload = {"aps"=>{"alert"=>params[:alert],
                         "sound"=>params[:sound],
                         "badge"=>params[:badge]}}.merge params[:kv]
      payload = {"payload"=>payload}
      data = {"tags"=>params[:tags],
              "devices"=>params[:devices],
              "exclude"=>params[:exclude]}.merge payload
      data = data.to_json

      post "/application/#{app_id}/notification", data
    end

    # GET get notification status
    def get_notification_status(app_id, notification_id)
      get "/application/#{app_id}/notification/#{notification_id}"
    end

    # GET all the devices with a tag
    def get_devices_by_tag(app_id, tag)
      get "/application/#{app_id}/tag/#{tag}"
    end
  end

  class Profile < AppushClient
    # GET device info
    def get_device(device_token)
      get "/device/#{device_token}"
    end

    # PUT register a device with tags
    def register_device(device_token, tags=[])
      data = {:tags=>tags}.to_json

      put "/device/#{device_token}", data
    end

    # DELETE unregister device
    def unregister_device(device_token)
      delete "/device/#{device_token}"
    end
  end

  class Application < AppushClient
    # POST
    def create_profile()
      post "/profile", "{}"
    end
  end
end
