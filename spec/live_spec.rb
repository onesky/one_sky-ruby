# encoding: utf-8

# this spec runs through live api calls
# and requires a real api key for the account
#
#   http://ruby-gem-tests.oneskyapp.com/
#
# before running this test we need to do
#
#   export ONESKY_API_KEY="the key"
#   export ONESKY_API_SECRET="the secret"
#
# the rake spec task skips these test
# you need to run
#
#   rake spec:live
#
require 'spec_helper'
require 'yaml'

describe OneSky, :live => true do
  
  let(:onesky_api_key)    { ENV["ONESKY_API_KEY"] }
  let(:onesky_api_secret) { ENV["ONESKY_API_SECRET"] }
  let(:project_name)      { "api-test" }
  let(:platform_id)       { 840 }
  let(:platform_code)     { "website" }
  
  let(:english_locale) { "en_US" }
  let(:chinese_locale) { "zh_CN" }
  
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
      en_us = locales.detect{|l| l["locale"] == english_locale }
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
      en_us = locales.detect{|l| l["locale"] == english_locale }
      en_us["name"]["eng"].should == "English (US)"
    end
  end
  
  context "translation" do
    let(:translation) do
      client.project(project_name).platform(platform_id).translation
    end
    
    it "input_phrases" do
      translation.input_phrases("test1" => "Test 1", "test2" => "Test 2")
    end
    
    it "input_strings - as strings" do
      translation.input_strings(["test1", "test2"])
    end
    
    it "input_strings - as hashes" do
      translation.input_strings([{:string => "Test 3", :string_key => "test3"}, {:string => "Test 4", :string_key => "test4"}])
    end
    
    it "input_string - as string" do
      translation.input_string("test5")
    end
    
    it "input_string - as hash" do
      translation.input_string({:string => "Test 6", :string_key => "test6"})
    end
    
    it "translate" do
      translation.translate("test1", chinese_locale, "测试一")
    end
    
    it "output" do
      output = translation.output
      output.should be_an_instance_of Hash
      
      output["Default"].should have_key(english_locale)
      output["Default"].should have_key(chinese_locale)
      
      output["Default"][english_locale].should have_key("test1")
    end
    
    it "output_for_locale" do
      output = translation.output_for_locale(chinese_locale)
      output.should be_an_instance_of Hash
      
      output["Default"].keys.should == [chinese_locale]
      output["Default"][chinese_locale].should have_key("test1")
    end
    
    def file(filename)
      path = File.join(File.dirname(__FILE__), "files", filename)
      File.open(File.expand_path(path))
    end
    
    it "upload_yaml" do
      translation.upload_yaml(file("example.yml"))
    end
    
    it "upload_po" do
      translation.upload_po(file("example.po"))
    end
    
    it "download_yaml" do
      yaml = translation.download_yaml(chinese_locale)
      yaml.should be_an_instance_of String
      
      hash = YAML.load(yaml)
      hash.should be_an_instance_of Hash
      
      hash[chinese_locale].should have_key("test1")
    end
    
    it "download_po" do
      po = translation.download_po(chinese_locale)
      po.should be_an_instance_of String
      
      # some way of verifying it looks like a po
      po.should match(%(msgid "test1"\nmsgstr "))
    end
  end
    
    
end