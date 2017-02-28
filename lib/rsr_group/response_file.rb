module RsrGroup
  class ResponseFile < Base

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
        @content   = ftp.gettextfile(@filename, nil)
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
      errors = @content.lines[0..-2].map do |line|
        DataRow.new(line, has_errors: true).to_h
      end.compact

      errors.select! { |e| !e[:error_code].nil? }

      @json.merge!(errors: errors)
    end

    def parse_econf
      details = @content.lines[2..-3].map do |line|
        DataRow.new(line).to_h
      end.compact

      @json.merge!({
        rsr_order_number: @content.lines[1].split(";")[2].chomp,
        details: details
      })
    end

    def parse_eship
      details = @content.lines[1..-3].map do |line|
        DataRow.new(line).to_h
      end.compact

      @json.merge!({
        rsr_order_number: @content.lines[0].split(";")[3].chomp,
        details: details
      })
    end

  end
end
