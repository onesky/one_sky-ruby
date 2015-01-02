require 'spec_helper'

describe OneSky::Client do

  let(:api_key) { "apikey" }
  let(:secret)  { "secret" }
  
  let(:client) { OneSky::Client.new(api_key, secret) }
  
  let(:fake_response) { mock("some response", :headers => {:content_type => "text/plain"}, :body => "response") }
  let(:fake_json) {     mock("json response", :headers => {:content_type => "json"}, :body => %|{"some": "json"}|) }
  
  describe "proxies" do
    describe "utility" do
      it "returns a OneSky::Utility instance" do
        client.utility.should be_an_instance_of OneSky::Utility
      end
      
      it "sets the client to itself" do
        client.utility.client.should == client
      end
    end
    
    describe "project" do
      it "returns a OneSky::Project instance" do
        client.project("some-project").should be_an_instance_of OneSky::Project
      end
      
      it "sets the client to itself" do
        client.project("some-project").client.should == client
      end
      
      it "sets the provided project name" do
        client.project("some-project").project_name.should == "some-project"
      end
    end
    
  end
  
  describe "get" do

    it "GETs the given path" do
      RestClient.should respond_to(:post)
      RestClient.should_receive(:get).with("https://api.oneskyapp.com/2/some_path/to/something", kind_of(Hash)).and_return(fake_response)
      client.get("some_path/to/something")
    end
    
    it "GETs the given path - when given a leading /" do
      RestClient.should_receive(:get).with("https://api.oneskyapp.com/2/some_path/to/something", kind_of(Hash)).and_return(fake_response)
      client.get("/some_path/to/something")
    end
    
    it "passes in the api key, timestamp, and a hash of the secret" do
      Time.freeze! do
        timestamp = Time.now.to_i.to_s
        RestClient.should_receive(:get).with(
          kind_of(String),
          {:params => {
            :"api-key" => api_key,
            :timestamp => timestamp,
            :"dev-hash" => Digest::MD5.hexdigest(timestamp + secret)
          },
          :content_type => "text/plain; charset=UTF-8",
          :"Onesky-Plugin" => "rudy-wrapper-old"}
        ).and_return(fake_response)
        client.get("some_path/to/something")
      end
    end
    
    it "adds any provided params" do
      Time.freeze! do
        timestamp = Time.now.to_i.to_s
        RestClient.should_receive(:get).with(
          kind_of(String),
          {:params => {
            :"api-key" => api_key,
            :timestamp => timestamp,
            :"dev-hash" => Digest::MD5.hexdigest(timestamp + secret),
            :some => "other param"
          },
          :content_type => "text/plain; charset=UTF-8",
          :"Onesky-Plugin" => "rudy-wrapper-old"}
        ).and_return(fake_response)
        client.get("some_path/to/something", :some => "other param")
      end
    end

    it "set plugin code for custom header" do
      Time.freeze! do
        timestamp = Time.now.to_i.to_s
        RestClient.should_receive(:get).with(
          kind_of(String),
          {:params => {
            :"api-key" => api_key,
            :timestamp => timestamp,
            :"dev-hash" => Digest::MD5.hexdigest(timestamp + secret)
          },
          :content_type => "text/plain; charset=UTF-8",
          :"Onesky-Plugin" => "fake_plugin_code"}
        ).and_return(fake_response)
        client.plugin_code = 'fake_plugin_code'
        client.get("some_path/to/something")
      end
    end
    
    context "with a json content_type" do
      it "parses the json" do
        RestClient.should_receive(:get).and_return(fake_json)
        client.get("some_path").should == {"some" => "json"}
      end
      
      it "raises an error if the response: is not OK" do
        fake_json.should_receive(:body).and_return(%|{"response": "bad"}|)
        RestClient.should_receive(:get).and_return(fake_json)
        expect {
          client.get("some_path")
        }.to raise_error(OneSky::ApiError)
      end
    end
    
    context "without a non-json content_type" do
      it "returns the body" do
        RestClient.should_receive(:get).and_return(fake_response)
        client.get("some_path").should == fake_response.body
      end
    end
  end
  
  describe "post" do

    it "POSTSs the given path" do
      RestClient.should respond_to(:post)
      RestClient.should_receive(:post).with("https://api.oneskyapp.com/2/some_path/to/something", kind_of(Hash)).and_return(fake_response)
      client.post("some_path/to/something")
    end
    
    it "passes in the api key, timestamp, and a hash of the secret" do
      Time.freeze! do
        timestamp = Time.now.to_i.to_s
        RestClient.should_receive(:post).with(
          kind_of(String),
          {
            :"api-key" => api_key,
            :timestamp => timestamp,
            :"dev-hash" => Digest::MD5.hexdigest(timestamp + secret),
            :content_type => "text/plain; charset=UTF-8",
            :"Onesky-Plugin" => "rudy-wrapper-old"
          }
        ).and_return(fake_response)
        client.post("some_path/to/something")
      end
    end
    
    it "adds any provided params" do
      Time.freeze! do
        timestamp = Time.now.to_i.to_s
        RestClient.should_receive(:post).with(
          kind_of(String),
          {
            :"api-key" => api_key,
            :timestamp => timestamp,
            :"dev-hash" => Digest::MD5.hexdigest(timestamp + secret),
            :some => "other param",
            :content_type => "text/plain; charset=UTF-8",
            :"Onesky-Plugin" => "rudy-wrapper-old"
          }
        ).and_return(fake_response)
        client.post("some_path/to/something", :some => "other param")
      end
    end

    it "set plugin code for custom header" do
      Time.freeze! do
        timestamp = Time.now.to_i.to_s
        RestClient.should_receive(:post).with(
          kind_of(String),
          {
            :"api-key" => api_key,
            :timestamp => timestamp,
            :"dev-hash" => Digest::MD5.hexdigest(timestamp + secret),
            :content_type => "text/plain; charset=UTF-8",
            :"Onesky-Plugin" => "fake_plugin_code"
          }
        ).and_return(fake_response)
        client.plugin_code = "fake_plugin_code"
        client.post("some_path/to/something")
      end
    end
    
    context "with a json content_type" do
      it "parses the json" do
        RestClient.should_receive(:post).and_return(fake_json)
        client.post("some_path").should == {"some" => "json"}
      end
      
      it "raises an error if the response: is not OK" do
        fake_json.should_receive(:body).and_return(%|{"response": "bad"}|)
        RestClient.should_receive(:post).and_return(fake_json)
        expect {
          client.post("some_path")
        }.to raise_error(OneSky::ApiError)
      end
    end
    
    context "without a non-json content_type" do
      it "returns the body" do
        RestClient.should_receive(:post).and_return(fake_response)
        client.post("some_path").should == fake_response.body
      end
    end
  end
end