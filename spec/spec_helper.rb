$:.unshift File.expand_path(File.dirname(__FILE__)+'/../lib')

require 'one_sky'
require 'time_freeze'

module OneSkySpecHelpers
  def create_project
    raise "Please set environment variables: ONESKY_API_KEY, ONESKY_API_SECRET and ONESKY_SPEC_PROJ (default: rubysdkspec) before running spec." unless [ENV["ONESKY_API_KEY"], ENV["ONESKY_API_SECRET"]].all?
    OneSky::Project.new(ENV["ONESKY_API_KEY"], ENV["ONESKY_API_SECRET"], ENV["ONESKY_SPEC_PROJ"] || "rubysdkspec")
  end  
end
