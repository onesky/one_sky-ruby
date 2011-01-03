# coding: utf-8
require 'helpers'

describe "Project" do
  include OneSkySpecHelpers

  before do
    @project = create_project
  end

  describe "#input" do
    # We use the spec description as the string sent to OneSky for translation.
    # ToDo: Make this DRY.
    it "returns true for a normal translate request." do
      @project.input("input returns true for a normal translate request.").should be_true
    end

    it "returns true when non-latin characters are passed (こんにちは世界)." do
      @project.input("input returns true when non-latin characters are passed (こんにちは世界).").should be_true
    end

    it "returns true when optional parameters are passed." do
      @project.input("input returns true when optional parameters are passed.", 
        :string_key => "string key", :string_context => "string context", :page => "page").should be_true
    end
  end

  describe "#input_bulk" do
    it "returns true for a normal translate request." do
      input = []
      input << {:string => "input_bulk returns true for a normal translate request (A).", :string_key => "input_bulk.key.1.a", :context => "input_bulk.context.1.a"}
      input << {:string => "input_bulk returns true for a normal translate request (B).", :string_key => "input_bulk.key.1.b", :context => "input_bulk.context.1.b"}
      input << {:string => "input_bulk returns true for a normal translate request (C)." }

      @project.input_bulk(input).should be_true
    end

    it "returns true when non-latin characters are passed (こんにちは世界)." do
      input = []
      input << {:string => "input_bulk returns true when non-latin characters are passed (こんにちは世界) (A).", :string_key => "input_bulk.key.2.a", :context => "input_bulk.context.2.a"}
      input << {:string => "input_bulk returns true when non-latin characters are passed (こんにちは世界) (B).", :string_key => "input_bulk.key.2.b", :context => "input_bulk.context.2.b"}
      input << {:string => "input_bulk returns true when non-latin characters are passed (こんにちは世界) (C)." }

      @project.input_bulk(input).should be_true
    end

    it "returns true when optional parameters are passed." do
      input = []
      input << {:string => "input_bulk returns true when optional parameters are passed (A).", :string_key => "input_bulk.key.3.a", :context => "input_bulk.context.3.a"}
      input << {:string => "input_bulk returns true when optional parameters are passed (B).", :string_key => "input_bulk.key.3.b", :context => "input_bulk.context.3.b"}
      input << {:string => "input_bulk returns true when optional parameters are passed (C)." }

      @project.input_bulk(input, {:page => "input_bulk.page.3"}).should be_true
    end
  end

  describe "#input_po" do
    it "returns true after uploading a file." do
      file_name = "#{File.dirname(__FILE__)}/data/en-us.po"
      @project.input_po("en-us", file_name).should be_true
    end
  end
end

