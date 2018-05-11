module RsrGroup
  class ResponseFile < Base

    attr_reader :filename
    attr_accessor :content, :mtime

    def initialize(options = {})
      requires!(options, :username, :password, :filename)

      @credentials    = options.select { |k, v| [:username, :password].include?(k) }
      @filename       = File.basename(options[:filename])
      @account_number = @filename.split('-')[2]
    end

    FILE_TYPES.each do |key, value|
      define_method("#{value.downcase}?".to_sym) do
        response_type == value
      end
    end 

    def self.get_each(options = {}, &block)
      requires!(options, :username, :password)

      Base.connect(options) do |ftp|
        ftp.chdir(RsrGroup.config.response_dir)

        @list = ftp.nlst("*.txt")
        @list.each do |file|
          resource         = new(options.merge(filename: file))
          resource.content = ftp.gettextfile(file, nil)
          resource.mtime   = ftp.mtime(file)
          yield(resource)
        end

        ftp.close
      end

      @list  
    end

    def self.all(options = {})
      requires!(options, :username, :password)

      Base.connect(options) do |ftp|
        ftp.chdir(RsrGroup.config.response_dir)
        @resp = ftp.nlst("*.txt")
        ftp.close
      end

      @resp
    end

    def content
      return @content if @content
      connect(@credentials) do |ftp|
        ftp.chdir(RsrGroup.config.response_dir)
        @mtime = ftp.mtime(@filename)
        @content = ftp.gettextfile(@filename, nil)
        ftp.close
      end
    end
    alias get_content content

    def response_type
      FILE_TYPES[@filename.split("-").first]
    end

    def to_json
      get_content

      if @content.length == 0
        raise ZeroByteFile.new("File is empty (filename: #{@filename})")
      end

      @json = {
        response_type: response_type,
        identifier: @content.lines[1].split(";")[0],
        filename: @filename,
        account_number: @account_number,
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
