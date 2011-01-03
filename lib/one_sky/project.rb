module OneSky
  # This is the main class used to interact with the OneSky API and maps to a project on their web site.
  class Project
    attr_accessor :api_key, :api_secret, :name

    # Provide the name of the project you created on the OneSky website. Also, the API key and secret shown there.
    def initialize(api_key, api_secret, name)
      raise ArgumentError, "api_key, api_secret, and name cannot be nil." unless [api_key, api_secret, name].all?
      @api_key, @api_secret, @name = api_key, api_secret, name
    end

    # Returns details about the project.
    def details
      get("/details")["project"]
    end

    # Returns an array of available languages.
    def languages
      get("/languages")["languages"]
    end

    # Returns the SSO URL for the given unique_id
    def get_sso_link(unique_id)
      get("/sso/get-link", {:"unique-id" => unique_id})["url"]
    end

    # Submits a string for translation.
    # Takes an optional hash of parameters, too:
    # * :string_key
    # * :context 
    # * :page
    def input(string, options = {})
      options = {:string => string}.merge(options)
      post("/string/input", hash_to_params(options))
      true
    end

    # Submits a bulk translation request.
    # Parameters:
    # * hashes - An array of hashes with mandatory key :string and optional keys (:string_key, :context)
    # * An optional hash with keys:
    #   * :page
    def input_bulk(hashes, options = {})
      arrs = hashes.inject([[],[],[]]) do |o,e|
        o[0] << e[:string]; o[1] << e[:string_key]; o[2] << e[:context]; o
      end

      post("/string/input-bulk", {:strings => arrs[0], :"string-keys" => arrs[1], :contexts => arrs[2]}.merge(options))
      true
    end

    # Uploads a PO file for the given language.
    # See #languages for a list of supported language codes.
    # Takes an optional hash of parameters:
    # * :page
    def input_po(language, file_name, options = {})
      response = post("/string/input-po", {:language => language, :file => File.new(file_name, "rb")}.merge(options), {}) 
      true
    end

    alias_method :upload_po, :input_po

    # Gets the strings with available translations.
    # Takes these optional parameters, too:
    # * :language
    # * :page
    # * :md5
    #--
    # ToDo: Probably need to expose MD5 response values for caching implementations.
    #++
    def output(options = {})
      get("/string/output", hash_to_params(options))["translation"]
    end

    # Downloads the compiled MO file for the given language and saves it as file_name.
    # See #languages for a list of supported language codes.
    # Takes an optional hash of parameters:
    # * :page
    def output_mo(language, file_name, options = {})
      response = get("/string/output-mo", {:language => language}.merge(options)) 
      File.open(file_name, "w") { |f| f.print response }
      true
    end

    alias_method :download_mo, :output_mo

    protected

    def hash_to_params(hash)
      hash.inject({}) { |o, (k,v)| o[k.to_s.gsub("_", "-").to_sym] = v; o }
    end
  
    def get(path, params = {}, options = {:content_type => "text/plain; charset=UTF-8"})
      params = {:"api-key" => @api_key, :"api-secret" => @api_secret, :"project" => @name}.merge(params)
      parse_response(RestClient.get([API_ROOT_URL, path].join, {:params => params}.merge(options)))
    end

    def post(path, params = {}, options = {:content_type => "text/plain; charset=UTF-8"})
      params = {:"api-key" => @api_key, :"api-secret" => @api_secret, :"project" => @name}.merge(params)
      parse_response(RestClient.post([API_ROOT_URL, path].join, params.merge(options)))
    end

    def parse_response(response)
      raise ApiHttpResponseError, "HTTP response status code: #{response.code.inspect}." unless response.code.eql?(200)
      # Do not post-process response if it isn't JSON. (ie. Binary file returned from /output_mo.)
      return response.body unless response.headers[:content_type] =~ /json/
      response_hash = JSON.parse(response)
      raise ApiError, response.body if response_hash.has_key?("response") and response_hash["response"] != "ok"
      response_hash
    end
  end
end
