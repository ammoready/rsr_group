$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'webmock/rspec'

require "rsr_group"

root = File.expand_path('../..', __FILE__)
Dir[File.join(root, "spec/support/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include SampleFiles
end
