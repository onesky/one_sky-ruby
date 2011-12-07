module OneSky
  
  # Implements the Utility API
  class Utility
    
    attr_reader :client
    
    def initialize(client)
      @client = client
    end
    
    # Get available locale list.
    def locales
      get("locales")["locales"]
    end
    
    # Get available platform type list.
    def platform_types
      get("platform-types")["types"]
    end
    
    # Get the Single-Sign-On link for logging in.
    def get_sso_link(unique_id, name)
      post("sso/get-link", {:"unique-id" => unique_id, :name => name})["url"]
    end
    
    protected
    
    def get(path)
      client.get(path)
    end
    
    def post(path, params)
      client.post(path, params)
    end
    
  end
end