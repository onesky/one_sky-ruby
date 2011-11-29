module OneSky
  
  # Implements the Project Management API for a given :project_name
  class Project
    attr_accessor :project_name, :client

    # Provide the name of the project, together with an instance of OneSky::Client.
    def initialize(project_name, client)
      @project_name = project_name
      @client = client
    end

    # Return all platforms in a project.
    def platforms
      get("project/platforms")["platforms"]
    end
    
    # Get the information of the project.
    def details
      get("project/details")["project"]
    end
    
    # Returns an API proxy for the Platform Management API for the given platform_id.
    def platform(platform_id)
      Platform.new(platform_id, client)
    end
    
    protected
    
    def get(path, params={})
      client.get(path, params.merge(:project => project_name))
    end

  end
end
