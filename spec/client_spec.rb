require 'helpers'
describe OneSky::Client do

  let(:api_key) { "apikey" }
  let(:secret)  { "secret" }
  
  let(:client) { OneSky::Client.new(api_key, secret) }
  
  let(:fake_response) { mock("some response", :headers => {:content_type => "text/plain"}, :body => "response") }
  let(:fake_json) {     mock("json response", :headers => {:content_type => "json"}, :body => %|{"some": "json"}|) }
  
  describe "get" do

    it "GETs the given path" do
      RestClient.should_receive(:get).with("https://api.oneskyapp.com/2/some_path/to/something", kind_of(Hash)).and_return(fake_response)
      client.get("some_path/to/something")
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
          :content_type => "text/plain; charset=UTF-8"}
        ).and_return(fake_response)
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
end