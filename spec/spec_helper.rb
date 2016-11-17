$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'webmock/rspec'

require "rsr_group"

root = File.expand_path('../..', __FILE__)
Dir[File.join(root, "spec/support/*.rb")].each { |f| require f }

RSpec.configure do |config|

  # configure options for dummy FTP connection
  config.before(:suite) do
    RsrGroup.configure do |config|
      config.ftp_host       = "ftp.host.com"
      config.submission_dir = File.join("eo", "incoming")
    end
  end

  config.include SampleFiles
end
