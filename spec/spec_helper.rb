$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'webmock/rspec'
require 'pp'

require "rsr_group"

root = File.expand_path('../..', __FILE__)
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

  # configure options for dummy FTP connection
  config.before(:suite) do
    RsrGroup.configure do |config|
      config.ftp_host       = "ftp.host.com"
      config.ftp_port       = "2222"
      config.submission_dir = File.join("eo", "incoming")
    end
  end

  config.include SampleFiles
end
