require 'json'
require 'rest_client'

module OneSky
  API_ROOT_URL = "https://api.oneskyapp.com/1"

  autoload :Project, 'one_sky/project'

  %w[ApiHttpResponseError ApiError].each { |e| const_set(e, Class.new(StandardError)) }
end
