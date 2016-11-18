module RsrGroup
  class ResponseFile < Base

    attr_reader :content
    attr_reader :credentials
    attr_reader :filename

    def initialize(options = {})
      requires!(options, :username, :password, :filename)

      @credentials = options.select { |k, v| [:username, :password].include?(k) }
      @filename    = options[:filename]
    end

    FILE_TYPES.each do |key, value|
      define_method("#{value.downcase}?".to_sym) do
        response_type == value
      end
    end

    def self.all(options = {})
      requires!(options, :username, :password)

      Base.connect(options) do |ftp|
        ftp.chdir(RsrGroup.config.response_dir)
        ftp.nlst("*.txt")
      end
    end

    def content
      return @content if @content
      connect(@credentials) do |ftp|
        ftp.chdir(RsrGroup.config.response_dir)
        @content = ftp.gettextfile(@filename, nil)
      end
    end
    alias get_content content

    def response_type
      FILE_TYPES[@filename.split("-").first]
    end

    def to_json
      get_content

      @json = {
        response_type: response_type,
        identifier: @content.lines[1].split(";")[0]
      }

      return parse_eerr  if error?
      return parse_econf if confirmation?
      return parse_eship if shipping?
    end

    private

    def parse_eerr
      errors = @content.lines[1..-2].map do |line|
        code = line.split(";")[-1].chomp
        next if code == "00000" # no error
        {
          stock_id: line.split(";")[2],
          code:     code,
          message:  ERROR_CODES[code],
        }
      end

      @json.merge!(errors: errors.compact)
    end

    def parse_econf
      details = @content.lines[2..-3].map do |line|
        { 
          stock_id:  line.split(";")[2],
          ordered:   line.split(";")[3].to_i,
          committed: line.split(";")[4].to_i,
        }
      end

      @json.merge!({
        rsr_order_number: @content.lines[1].split(";")[2].chomp,
        details: details.compact
      })
    end

    def parse_eship
      @json.merge!(info: "")
    end

  end
end
