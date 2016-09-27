require 'rsr_group/version'

require 'csv'
require 'date'
require 'net/ftp'

require 'rsr_group/base'
require 'rsr_group/department'
require 'rsr_group/inventory'
require 'rsr_group/user'

module RsrGroup
  class NotAuthenticated < StandardError; end
  class UnknownDepartment < StandardError; end
end
