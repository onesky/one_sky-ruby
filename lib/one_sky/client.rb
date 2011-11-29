module OneSky
  class Client
    attr_accessor :api_key, :api_secret

    # Provide the name of the project you created on the OneSky website. Also, the API key and secret shown there.
    def initialize(api_key, api_secret)
      raise ArgumentError, "api_key, api_secret cannot be nil." unless [api_key, api_secret].all?
      @api_key, @api_secret = api_key, api_secret
    end
    
    API_ROOT_URL = "https://api.oneskyapp.com/2/".freeze
    
    def get(path, params = {}, options = nil)
      fetch_response :get, path, params, options
    end

    def post(path, params = {}, options = nil)
      fetch_response :post, path, params, options
    end
  
    protected

    def hash_to_params(hash)
      hash.inject({}) { |o, (k,v)| o[k.to_s.gsub("_", "-").to_sym] = v; o }
    end

    def authorization_params
      timestamp = Time.now.to_i.to_s
      {:"api-key" => @api_key, :timestamp => timestamp, :"dev-hash" => Digest::MD5.hexdigest(timestamp + @api_secret)}
    end
    
    def fetch_response(http_verb, path, params, options)
      options ||= {:content_type => "text/plain; charset=UTF-8"}
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
      URI.join(API_ROOT_URL, path).to_s
    end

    def parse_response(response)
      # Do not post-process response if it isn't JSON. (ie. Binary file returned from /output_mo.)
      return response.body unless response.headers[:content_type] =~ /json/
      response_hash = JSON.parse(response.body)

      raise ApiError, response.body if response_hash.has_key?("response") and response_hash["response"] != "ok"
      response_hash
    end
  end
end