module RsrGroup
  class User < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def authenticated?
      Net::FTP.open(FTP_HOST, @options[:username], @options[:password]) do |ftp|
        ftp.status
      end

      true
    rescue Net::FTPPermError
      false
    end

  end
end
