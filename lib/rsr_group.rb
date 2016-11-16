require 'rsr_group/version'

require 'csv'
require 'date'
require 'net/ftp'

require 'rsr_group/base'
require 'rsr_group/department'
require 'rsr_group/inventory'
require 'rsr_group/order'
require 'rsr_group/order_detail'
require 'rsr_group/order_ffl'
require 'rsr_group/order_recipient'
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
    attr_accessor :vendor_email

    def initialize
      @vendor_email = nil
    end
  end
end
