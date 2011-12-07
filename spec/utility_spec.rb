require 'spec_helper'

describe OneSky::Utility do
  let(:api_key) { "apikey" }
  let(:secret)  { "secret" }
  
  let(:client) { OneSky::Client.new(api_key, secret) }
  let(:utility) { client.utility }
  
  
  describe "locales" do
    
    let(:example) do
      # example from the api docs
      {
          "locales" => [
              {
                  "locale" => "en_US",
                  "name" => {
                      "eng" => "English (US)",
                      "local" => "English (US)"
                  },
                  "locale_ios" => "en"
              },
              {
                  "locale" => "af_ZA",
                  "name" => {
                      "eng" => "Afrikaans",
                      "local" => "Afrikaans"
                  }
              },
              {
                  "locale" => "sq_AL",
                  "name" => {
                      "eng" => "Albanian",
                      "local" => "Shqip"
                  }
              }
          ]
      }
    end
    
    it "calls /locales" do
      client.should_receive(:get).with("locales").and_return(example)
      utility.locales.should == example["locales"]
    end
  end
  
  describe "platform_types" do
    
    let(:example) do
      {
          "types" => [
              {
                  "name" => "iPhone/iPad App",
                  "code" => "ios"
              },
              {
                  "name" => "Android App",
                  "code" => "android"
              },
              {
                  "name" => "Website",
                  "code" => "website"
              },
              {
                  "name" => "Miscellaneous",
                  "code" => "misc"
              }
          ]
      }
    end
    
    it "calls /platform-types" do
      client.should_receive(:get).with("platform-types").and_return(example)
      utility.platform_types.should == example["types"]
    end
  end
  
  describe "get_sso_link" do
    
    let(:unique_id) { "abc123" }
    let(:name) { "fred" }
    
    let(:example) do
      {
          "url" => "http:\/\/global.oneskyapp.com\/?time=1290495566&id=abc@oneskyapp.com&data=d98e3fc22ba4bce8537bfef7929f1fc5&name=Leon",
          "md5" => "7f4d51e53b0e2fec49262840caa29720"
      }
    end
    
    it "calls /sso/get-link" do
      client.should_receive(:post).with("sso/get-link", :"unique-id" => unique_id, :name => name).and_return(example)
      utility.get_sso_link(unique_id, name).should == example["url"]
    end
  end
  
end
