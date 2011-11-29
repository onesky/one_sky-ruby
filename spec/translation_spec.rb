require 'spec_helper'

describe OneSky::Translation do
  let(:api_key) { "apikey" }
  let(:secret)  { "secret" }
  let(:project_name) { "some-project" }
  let(:platform_id) { 123 }
  
  let(:client) { OneSky::Client.new(api_key, secret) }
  let(:project) { client.project(project_name) }
  let(:platform) { project.platform(platform_id) }
  let(:translation) { platform.translation }
  
  describe "input_strings" do
    
    let(:string_array) {
      ["test1", "test2"]
    }
    
    let(:hash_array) {
      [{:string => "test1"}, {:string => "test2"}]
    }
    
    context "with an array of strings" do
      it "calls /string/input" do
        client.should_receive(:post).with("string/input", :input => JSON.dump(hash_array), :"platform-id" => platform_id)
        
        translation.input_strings(string_array)
      end
    end
    
    context "with an array of hashes" do
      it "calls /string/input" do
        client.should_receive(:post).with("string/input", :input => JSON.dump(hash_array), :"platform-id" => platform_id)
        
        translation.input_strings(hash_array)
      end
    end
    
    context "with a complex array of hashes" do
      it "dasherizes the keys" do
        original = [{:string => "Test 1", :string_key => "test1"}]
        dasherized = [{:string => "Test 1", :"string-key" => "test1"}]
        
        client.should_receive(:post).with("string/input", :input => JSON.dump(dasherized), :"platform-id" => platform_id)
        
        translation.input_strings(original)
       end
    end
  end
  
  describe "input_string" do
    it "defers to input_strings" do
      translation.should_receive(:input_strings).with(["test1"])
      translation.input_string("test1")
    end
  end
  
  describe "translate" do
    
    let(:string_key) { "test1" }
    let(:locale) { "en_US" }
    let(:string) { "Test 1" }
    
    it "calls /string/translate" do
      client.should_receive(:post).with(
        "string/translate",
        :"string-key" => string_key,
        :locale => locale,
        :translation => string,
        :"platform-id" => platform_id
      )
      
      translation.translate(string_key, locale, string)
    end
  end
  
  describe "output" do
    
    let(:example) do
      {
          "translation" => {
              "Tag A" => {
                  "Locale A" => {
                      "String Key A" => "string",
                      "String Key B" => {
                          "Context A" => "string",
                          "Context B" => "string"
          	        }
                  },
                  "Locale B" => {
                      "String Key A" => "string"
                  }
              },
              "Tag B" => {
                  "Locale A" => {
                      "String Key C" => "string"
                  }
              }
          },
          "md5" => "95e6198f16ea363291dfa9bc18282545"
      }
    end
    
    it "calls /string/output" do
      client.should_receive(:get).with("string/output", :"platform-id" => platform_id).and_return(example)
      translation.output.should == example["translation"]
    end
    
    context "for_locale" do
      it "calls /string/output with the locale" do
        client.should_receive(:get).with("string/output", :"platform-id" => platform_id, :locale => "en_US").and_return(example)
        translation.output_for_locale("en_US").should == example["translation"]
      end
    end
  end
end
