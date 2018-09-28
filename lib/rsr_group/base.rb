module RsrGroup
  class Base

    KEYDEALER_DIR = 'keydealer'.freeze
    DEFAULT_DIR   = 'ftpdownloads'.freeze
    QTY_FILENAME  = 'IM-QTY-CSV.csv'.freeze
    MAP_FILENAME  = 'retail-map.csv'.freeze
    DEFAULT_CATALOG_FILENAME   = 'rsrinventory-new.txt'.freeze
    KEYDEALER_CATALOG_FILENAME = 'rsrinventory-keydlr-new.txt'.freeze

    def self.connect(options = {})
      requires!(options, :username, :password)

      Net::FTP.open(RsrGroup.config.ftp_host, options[:username], options[:password]) do |ftp|
        ftp.debug_mode = RsrGroup.config.debug_mode
        ftp.passive = true
        yield ftp
      end
    end

    protected

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

    # Wrapper to `self.requires!` that can be used as an instance method.
    def requires!(*args)
      self.class.requires!(*args)
    end

    # Instance methods become class methods through inheritance
    def connect(options)
      self.class.connect(options) do |ftp|
        yield ftp
      end
    end

  end
end
