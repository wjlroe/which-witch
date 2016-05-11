require 'webmock/rspec'

require_relative './support/file_fixtures'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end
