module RsrGroup
  class User < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def authenticated?
      connect(@options) do |ftp| 
        ftp.status
        ftp.close
      end
      return true
    rescue RsrGroup::NotAuthenticated
      false
    end

  end
end
