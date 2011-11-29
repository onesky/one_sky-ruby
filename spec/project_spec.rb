require 'spec_helper'

describe OneSky::Project do
  let(:api_key) { "apikey" }
  let(:secret)  { "secret" }
  let(:project_name) { "some-project" }
  
  let(:client) { OneSky::Client.new(api_key, secret) }
  let(:project) { client.project(project_name) }
  
  describe "proxies" do
    
    describe "platform" do
      
      let(:platform_id) { 123 }
      let(:platform) { project.platform(platform_id) }
      
      it "returns a OneSky::Platform instance" do
        platform.should be_an_instance_of OneSky::Platform
      end
      
      it "sets the client to itself" do
        platform.client.should == client
      end
      
      it "sets the provided platform_id" do
        platform.platform_id.should == platform_id
      end
    end
    
  end
  
  describe "platforms" do
    
    let(:example) do
      {
          "platforms" => [
              {
                  "id" => 1,
                  "type" => "iPhone/iPad App",
                  "code" => "ios"
              },
              {
                  "id" => 2,
                  "type" => "Miscelleneous",
                  "code" => "misc",
                  "description" => "database"
              }
          ]
      }
    end
    
    it "calls /project/platforms" do
      # examples from the api docs
      client.should_receive(:get).with("project/platforms", :project => project_name).and_return(example)
      project.platforms.should == example["platforms"]
    end
  end
  
  describe "details" do
    
    let(:example) do
      {
          "project" => {
              "name" => "Website",
              "base_locale" => "en_US"
          }
      }
    end
    
    it "calls /project/details" do
      client.should_receive(:get).with("project/details", :project => project_name).and_return(example)
      project.details.should == example["project"]
    end
  end
  
end
