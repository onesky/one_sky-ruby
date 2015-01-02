require 'json'
require 'rest_client'
require 'digest/md5'

module OneSky
  
  # Base implemention of an API client
  # based on the one sky api version 2.
  # 
  #   http://developer.oneskyapp.com/api/list/v/2
  #
  class Client
    attr_accessor :api_key, :api_secret, :plugin_code

    # Provide the name of the project you created on the OneSky website. Also, the API key and secret shown there.
    def initialize(api_key, api_secret)
      raise ArgumentError, "api_key, api_secret cannot be nil." unless [api_key, api_secret].all?
      @api_key, @api_secret = api_key, api_secret

      # code for custom header
      @plugin_code = 'rudy-wrapper-old'
    end
    
    # Api version 2
    API_ROOT_URL = "https://api.oneskyapp.com/2/".freeze
    
    def get(path, params = {}, options = nil)
      fetch_response :get, path, params, options
    end

    def post(path, params = {}, options = nil)
      fetch_response :post, path, params, options
    end
  
    # Returns an API proxy for the Project Management API
    def project(name)
      Project.new(name, self)
    end
    
    # Returns an API proxy for the Utility API
    def utility
      Utility.new(self)
    end
    
    protected

    # dev-hash = MD5( CONCATENATE( timestamp , YOUR_API_SECRET ) )
    def authorization_params
      timestamp = Time.now.to_i.to_s
      {:"api-key" => self.api_key, :timestamp => timestamp, :"dev-hash" => Digest::MD5.hexdigest(timestamp + self.api_secret)}
    end
    
    def fetch_response(http_verb, path, params, options)
      options ||= {:content_type => "text/plain; charset=UTF-8"}
      options = options.merge({:"Onesky-Plugin" => @plugin_code})
      params = authorization_params.merge(params)
      path = api_path(path)
      
      response = case http_verb
      when :get
        RestClient.get(path, {:params => params}.merge(options))
      when :post
        RestClient.post(path, params.merge(options))
      else
        raise "bad http verb"
      end
      
      parse_response(response)
    end
    
    def api_path(path)
      URI.join(API_ROOT_URL, path.gsub(/^\//, "")).to_s
    end

    def parse_response(response)
      # Do not post-process response if it isn't JSON. (ie. Binary file returned from /output_mo.)
      return response.body unless response.headers[:content_type] =~ /json/
      response_hash = JSON.parse(response.body)

      raise ApiError, response.body if response_hash.has_key?("response") and (response_hash["response"] != "ok" && response_hash["response"] != 'upload-in-progress')
      response_hash
    end
  end
end