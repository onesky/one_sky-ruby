require 'json'
require 'rest_client'
require 'digest/md5'

module OneSky
  API_ROOT_URL = "https://api.oneskyapp.com/1"

  autoload :Project, 'one_sky/project'
  autoload :Client,  'one_sky/client'

  class ApiError < StandardError; end
end
