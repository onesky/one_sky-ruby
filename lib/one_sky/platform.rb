module OneSky
  
  # Implements the Platform Management API for a given :platform_id
  class Platform
    
    attr_accessor :platform_id, :client

    # Provide the id of the platform, together with an instance of OneSky::Client.
    def initialize(platform_id, client)
      @platform_id = platform_id
      @client = client
    end
    
    # Get the information of the platform.
    def details
      get("platform/details")["platform"]
    end
    
    # Get the details of activated locales for a platform.
    def locales
      get("platform/locales")["locales"]
    end
    
    # Returns an API proxy for the Translation I/O API for this platform
    def translation
      Translation.new(platform_id, client)
    end
    
    protected
    
    def get(path, params={})
      client.get(path, params.merge(:"platform-id" => platform_id))
    end

  end
end