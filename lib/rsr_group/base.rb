module RsrGroup
  class Base

    FTP_HOST = 'ftp.rsrgroup.com'

    protected

    # Wrapper to `self.requires!` that can be used as an instance method.
    def requires!(*args)
      self.class.requires!(*args)
    end

    def self.requires!(hash, *params)
      params.each do |param|
        if param.is_a?(Array)
          raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

          valid_options = param[1..-1]
          raise ArgumentError.new("Parameter: #{param.first} must be one of: #{valid_options.join(', ')}") unless valid_options.include?(hash[param.first])
        else
          raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
        end
      end
    end

    def connect(options = {})
      requires!(options, :username, :password)

      Net::FTP.open(FTP_HOST, options[:username], options[:password]) do |ftp|
        yield ftp
      end
    # TODO: Disable this rescue for now, so we can figure out what's happening when used in an actual app.
    # rescue Net::FTPPermError
    #   raise RsrGroup::NotAuthenticated
    end

  end
end
