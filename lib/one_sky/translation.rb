module OneSky
  
  # Implements the Translation I/O API for a given :platform_id
  class Translation
    
    attr_reader :platform_id, :client
    
    # Provide the id of the platform, together with an instance of OneSky::Client.
    def initialize(platform_id, client)
      @platform_id = platform_id
      @client = client
    end

    # Add new strings to be translated.
    #
    # 
    def input(strings)
      post("string/input", :input => JSON.dump(input_string_array(strings)))
    end
    
    
    # Add translation to a string.
    def translate(string_key, locale, translation)
      post("string/translate", :"string-key" => string_key, :locale => locale, :translation => translation)
    end
    
    # Get the strings with translations.
    def output
      get("string/output")
    end
    
    # Download strings and translations as RUBY_YAML file.
    def download_yaml(locale)
      get("string/download", :locale => locale, :format => "RUBY_YAML")
    end
    
    protected

    def get(path, params={})
      client.get(path, params.merge(:"platform-id" => platform_id))
    end
    
    def post(path, params={})
      client.post(path, params.merge(:"platform-id" => platform_id))
    end
    
    def input_string_array(strings)
      Array(strings).map{|s| input_string(s)}
    end
    
    def input_string(string)
      case string
      when String
        {:string => string}
      else
        dashify_string_hash(string)
      end
    end
    
    def dashify_string_hash(string_hash)
      output = Hash.new
      string_hash.each do |key, value|
        dashed = key.to_s.gsub("_", "-").to_sym
        output[dashed] = value
      end
      output
    end

  end
end