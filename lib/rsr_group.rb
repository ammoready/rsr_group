require 'rsr_group/version'

require 'csv'
require 'date'
require 'net/ftp'
require 'smarter_csv'

require 'rsr_group/base'
require 'rsr_group/constants'
require 'rsr_group/chunker'
require 'rsr_group/data_row'
require 'rsr_group/department'
require 'rsr_group/inventory'
require 'rsr_group/order'
require 'rsr_group/order_detail'
require 'rsr_group/order_ffl'
require 'rsr_group/order_recipient'
require 'rsr_group/response_file'
require 'rsr_group/user'

module RsrGroup
  class NotAuthenticated < StandardError; end
  class UnknownDepartment < StandardError; end

  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor :debug_mode
    attr_accessor :ftp_host
    attr_accessor :submission_dir
    attr_accessor :response_dir
    attr_accessor :vendor_email

    def initialize
      @debug_mode     ||= false
      @ftp_host       ||= "ftp.rsrgroup.com"
      @submission_dir ||= File.join("eo", "incoming")
      @response_dir   ||= File.join("eo", "outgoing")
      @vendor_email   ||= nil
    end
  end
end
