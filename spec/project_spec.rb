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
    lambda { @project.details }.should raise_error OneSky::ApiError
  end

  describe "#details" do
    it "returns project name among other things." do
      @project.details["name"].should == @project.name
    end
  end

  describe "#languages" do
    it "returns an array." do
      @project.languages.should be_an(Array)
    end
  end

  describe "#get_sso_link" do
    it "returns a URL string." do
      @project.get_sso_link("rspec_process").should match /^http.*$/
    end
  end
end
