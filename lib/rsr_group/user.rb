module RsrGroup
  class User < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def authenticated?
      connect(@options) { |ftp| ftp.status }
      true
    rescue RsrGroup::NotAuthenticated
      false
    end

  end
end
