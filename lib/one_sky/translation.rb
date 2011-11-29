module OneSky
  
  # Implements the Translation I/O API for a given :platform_id
  class Translation
    
    attr_reader :platform_id, :client
    
    # Provide the id of the platform, together with an instance of OneSky::Client.
    def initialize(platform_id, client)
      @platform_id = platform_id
      @client = client
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

    # Returns the activated locales for the platform
    def locales
      get("platform/locales")["locales"]
    end

    protected

    def get(path, params={})
      client.get(path, params.merge(:"platform-id" => platform_id))
    end
    
    def hash_to_params(hash)
      hash.inject({}) { |o, (k,v)| o[k.to_s.gsub("_", "-").to_sym] = v; o }
    end
    # 
    # 
    # 
    # # Submits a bulk translation request.
    # # Parameters:
    # # * hashes - An array of hashes with mandatory key :string and optional keys (:string_key, :context, :description)
    # # * An optional hash with keys:
    # #   * :page
    # def input_bulk(hashes, options = {})
    #   arrs = hashes.inject([[],[],[]]) do |o,e|
    #     o[0] << e[:string]; o[1] << e[:string_key]; o[2] << e[:context]; o
    #   end
    # 
    #   post("/string/input-bulk", {:strings => arrs[0], :"string-keys" => arrs[1], :contexts => arrs[2]}.merge(options))
    #   true
    # end
    # 
    # # Uploads a PO file for the given language.
    # # See #languages for a list of supported language codes.
    # # Takes an optional hash of parameters:
    # # * :page
    # def input_po(language, file_name, options = {})
    #   response = post("/string/input-po", {:language => language, :file => File.new(file_name, "rb")}.merge(options), {}) 
    #   true
    # end
    # 
    # alias_method :upload_po, :input_po
    # 
    # # Gets the strings with available translations.
    # # Takes these optional parameters, too:
    # # * :language
    # # * :page
    # # * :md5
    # #--
    # # ToDo: Probably need to expose MD5 response values for caching implementations.
    # #++
    # def output(options = {})
    #   get("/string/output", hash_to_params(options))["translation"]
    # end
    # 
    # # Downloads the compiled MO file for the given language and saves it as file_name.
    # # See #languages for a list of supported language codes.
    # # Takes an optional hash of parameters:
    # # * :page
    # def output_mo(language, file_name, options = {})
    #   response = get("/string/output-mo", {:language => language}.merge(options)) 
    #   File.open(file_name, "w") { |f| f.print response }
    #   true
    # end
    # 
    # alias_method :download_mo, :output_mo

  end
end