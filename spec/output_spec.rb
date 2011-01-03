# coding: utf-8
require 'helpers'

describe "Project" do
  include OneSkySpecHelpers

  before do
    @project = create_project
  end

  describe "#output" do
    it "returns a hash with a parent key called 'Default'" do
      @project.output.has_key?("Default").should be_true
    end

    it "returns a hash with a parent key called 'Default' when optional parameters are passed." do
      @project.output({:context => "Default"}).has_key?("Default").should be_true
    end
  end

  describe "#output_mo" do
    it "creates a file." do
      file_name = "#{File.dirname(__FILE__)}/data/output.mo"
      @project.output_mo("en-us", file_name)
      File.exists?(file_name).should be_true
      File.delete(file_name)
    end

    it "raises an error if an invalid language code is supplied." do
      file_name = "#{File.dirname(__FILE__)}/data/output.2.mo"
      lambda { @project.output_mo("en-xx", file_name) }.should raise_error
    end
  end
end

