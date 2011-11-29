require 'spec_helper'

describe OneSky::Platform do
  let(:api_key) { "apikey" }
  let(:secret)  { "secret" }
  let(:project_name) { "some-project" }
  let(:platform_id) { 123 }
  
  let(:client) { OneSky::Client.new(api_key, secret) }
  let(:project) { client.project(project_name) }
  let(:platform) { project.platform(platform_id) }
  
  describe "proxies" do
    
    describe "translation" do
      
      let(:translation) { platform.translation }
      
      it "returns a OneSky::Translation instance" do
        translation.should be_an_instance_of OneSky::Translation
      end
      
      it "sets the client to itself" do
        translation.client.should == client
      end
      
      it "sets the same platform_id" do
        translation.platform_id.should == platform_id
      end
    end
    
  end
  
  describe "details" do
    
    let(:example) do
      # example from the api docs
      # but with the outer key as "platform" (the docs say "project")
      {
          "platform" => {
              "name" => "Website",
              "base_locale" => "en_US",
              "type" => {
                  "name" => "iPhone/iPad App",
                  "code" => "ios"
              }
          }
      }
    end
    
    it "calls /platform/details" do
      # example from the api docs
      # but with the outer key as "platform" (the docs say "project")
      client.should_receive(:get).with("platform/details", :"platform-id" => platform_id).and_return(example)
      platform.details.should == example["platform"]
    end
  end
  
  describe "locales" do
    
    let(:example) do
      {
          "locales" => [
              {
                  "locale" => "en_US",
                  "name" => {
                  	"eng" => "English (US)",
                  	"local" => "English (US)"
                  },
                  "locale_ios" => "en",
                  "is_active" => true,
                  "is_private" => false,
                  "string_select_threshold" => 3,
                  "string_confirm_threshold" => 20,
                  "completeness" => 0,
              },
              {
                  "locale" => "zh_TW",
                  "name" => {
            	      	"eng" => "Traditional Chinese",
                  	  "local" => "*some-chinese*"
                  },
                  "locale_ios" => "zh-Hant",
                  "is_active" => true,
                  "is_private" => false,
                  "string_select_threshold" => 3,
                  "string_confirm_threshold" => 20,
                  "completeness" => 0,
              },
           ]
      }
    end
    
    it "calls /platform/locales" do
      # examples from the api docs
      client.should_receive(:get).with("platform/locales", :"platform-id" => platform_id).and_return(example)
      platform.locales.should == example["locales"]
    end
  end
  
end
