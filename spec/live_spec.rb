# this spec runs through live api calls
# and requires a real api key for the account
#   http://ruby-gem-tests.oneskyapp.com/
#

require 'spec_helper'

describe OneSky, :tags => :live do
  
  let(:onesky_api_key)    { ENV["ONESKY_API_KEY"] }
  let(:onesky_api_secret) { ENV["ONESKY_API_SECRET"] }
  let(:project_name)      { "api-test" }
  let(:platform_id)       { 840 }
  let(:platform_code)     { "website" }
  
  let(:client) do
    client = OneSky::Client.new(onesky_api_key, onesky_api_secret)
  end
  
  context "utility apis" do
    let(:utility) do
      client.utility
    end
    
    it "locales" do
      locales = utility.locales
      locales.should be_an_instance_of Array
      locales.should_not be_empty
      en_us = locales.detect{|l| l["locale"] == "en_US" }
      en_us["name"]["eng"].should == "English (US)"
    end
    
    it "platform_types" do
      types = utility.platform_types
      types.should be_an_instance_of Array
      types.should_not be_empty
      website = types.detect{|t| t["code"] == platform_code }
      website.should == {"name" => "Website", "code" => platform_code}
    end
    
    it "get_sso_link" do
      link = utility.get_sso_link(123, "fred")
      link.should be_an_instance_of String
      link.should match(".oneskyapp.com/")
    end
  end
  
  context "project" do
    let(:project) do
      client.project(project_name)
    end
    
    it "details" do
      details = project.details
      details.should be_an_instance_of Hash
      details["name"].should == project_name
    end
    
    it "platforms" do
      platforms = project.platforms
      platforms.should be_an_instance_of Array
      platforms.should_not be_empty
      
      expected = platforms.detect{|p| p["id"]== platform_id}
      expected.should be_an_instance_of Hash
      expected["code"].should == platform_code
    end
  end
  
  context "platform" do
    let(:platform) do
      client.project(project_name).platform(platform_id)
    end
    
    it "details" do
      details = platform.details
      details.should be_an_instance_of Hash
      details["project"].should == project_name
      details["type"]["code"].should == platform_code
    end
    
    it "locales" do
      locales = platform.locales
      locales.should be_an_instance_of Array
      locales.should_not be_empty
      en_us = locales.detect{|l| l["locale"] == "en_US" }
      en_us["name"]["eng"].should == "English (US)"
    end
  end
end