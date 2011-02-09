require 'helpers'

describe "Project" do
  include OneSkySpecHelpers

  it "raises an error when initialization values are nil." do
    lambda { @project = OneSky::Project.new(nil, nil, nil) }.should raise_error ArgumentError
  end
end

describe "Project" do
  include OneSkySpecHelpers

  before do
    @project = create_project
  end

  it "raises an error when incorrect API credentials are passed." do
    @project.api_secret = "wrong secret"
    lambda { @project.details }.should raise_error RestClient::Exception
  end

  describe "#details" do
    it "returns project name among other things." do
      @project.details["name"].should == @project.name
    end
  end

  describe "#types" do
    it "returns an array." do
      types = @project.types
      types.should be_an(Array)
      types.size.should > 0
    end
  end

  describe "#languages" do
    it "returns an array." do
      langs = @project.languages
      langs.should be_an(Array)
      langs.size.should > 0
    end
  end

  describe "#info" do
    it "returns a hash." do
      info = @project.info
      info.should be_an(Hash)
      info.has_key?("name").should be_true
    end
  end

  describe "#get_sso_link" do
    it "returns a URL string." do
      @project.get_sso_link("rspec_process").should match /^http.*$/
    end
  end
end
