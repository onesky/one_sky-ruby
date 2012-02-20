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
    #   expects an array of strings, or an array of hashes [{:string_key => k, :string => v}, ...]
    def input_strings(strings, tag = "Default")
      post("string/input", :input => format_input_strings(strings), :tag => tag)
    end
    
    # Add new strings to be translated.
    #   expects a string, or a hash of {:string_key => k, :string => v}
    def input_string(string, tag = "Default")
      input_strings([string], tag)
    end
    
    # Add new strings to be translated.
    #   expects a hash of {"string_key1" => "String 1", "string_key2" => "String 2"}
    def input_phrases(phrases, tag = "Default")
      strings = phrases.map do |string_key, string|
        {:string_key => string_key, :string => string}
      end
      input_strings(strings, tag)
    end
    
    # Add translation to a string.
    def translate(string_key, locale, translation)
      post("string/translate", :"string-key" => string_key, :locale => locale, :translation => translation)
    end
    
    # Get the strings with translations.
    def output
      get_output
    end
    
    # Get the strings for a particular locale.
    def output_for_locale(locale)
      get_output(locale)
    end
    
    YAML_FORMAT = "RUBY_YAML".freeze
    PO_FORMAT = "GNU_PO".freeze
    
    # I don't believe these work right now.
    
      # Upload a string file to add new strings. In RUBY_YAML format.
      def upload_yaml(file)
        upload_file(file, YAML_FORMAT)
      end
    
      # Upload a string file to add new strings. In GNU_PO format.
      def upload_po(file)
        upload_file(file, PO_FORMAT)
      end
    
    # Download strings and translations as string file. In RUBY_YAML format.
    def download_yaml(locale)
      download_file(locale, YAML_FORMAT)
    end
    
    # Download strings and translations as string file. In GNU_PO format.
    def download_po(locale)
      download_file(locale, PO_FORMAT)
    end
    
    protected
    
    # Get the strings with translations.
    def get_output(locale=nil)
      options = {}
      options[:locale] = locale if locale
      
      get("string/output", options)["translation"]
    end
    
    # Upload a string file to add new strings.
    def upload_file(file, format)
      post("string/upload", :file => file, :format => format)
    end
    
    # Download strings and translations as string file.
    def download_file(locale, format)
      get("string/download", :locale => locale, :format => format)
    end
    
    def get(path, params={})
      client.get(path, params.merge(:"platform-id" => platform_id))
    end
    
    def post(path, params={})
      client.post(path, params.merge(:"platform-id" => platform_id))
    end
    
    def format_input_strings(strings)
      JSON.dump(strings.map{|string| format_input_string(string)})
    end
    
    def format_input_string(string)
      case string
      when String
        {:string => string}
      when Hash
        dashify_string_hash(string)
      else
        raise "input string must either be a string, or a hash"
      end
    end
    
    # convert to "string-key" not "string_key"
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
