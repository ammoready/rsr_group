module RsrGroup
  class Base

    FTP_HOST = 'ftp.rsrgroup.com'

    SHIPPING_CARRIERS = %w(UPS USPS)

    SHIPPING_METHODS = {
      "Grnd" => "Ground",
      "1Day" => "Next Day Air",
      "2Day" => "2nd Day Air",
      "3Day" => "3 Day Select", 
      "NDam" => "Next Day Early AM",
      "NDAS" => "Next Day Air Saver",
      "PRIO" => "Priority"
    }

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
        ftp.passive = true
        yield ftp
      end
    end

  end
end
