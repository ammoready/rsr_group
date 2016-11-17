module RsrGroup
  class Order < Base

    attr_reader :credentials
    attr_reader :identifier
    attr_reader :timestamp
    attr_reader :sequence_number
    attr_accessor :recipients

    LINE_TYPES = {
      "00" => "file_header",
      "10" => "order_header",
      "11" => "ffl_dealer",
      "20" => "order_detail",
      "90" => "order_trailer",
      "99" => "file_trailer"
    }

    def initialize(options = {})
      requires!(options, :sequence_number, :username, :password, :identifier)

      @credentials     = options.select { |k, v| [:username, :password].include?(k) }
      @identifier      = options[:identifier]
      @sequence_number = "%04d" % options[:sequence_number] # Leading zeros are required
      @timestamp       = Time.now.strftime("%Y%m%e")
      @recipients      = options[:recipients] || []
    end

    def header
      ["FILEHEADER", LINE_TYPES.key("file_header"), customer_number, @timestamp, @sequence_number].join(";")
    end

    def footer
      ["FILETRAILER", LINE_TYPES.key("file_trailer"), ("%05d" % recipients.length)].join(";")
    end

    def filename
      name = ["EORD", customer_number, timestamp, sequence_number].join("-")
      [name, ".txt"].join
    end

    def recipients
      @recipients ||= []
    end

    def to_txt
      txt = header + "\n"
      recipients.each do |recipient|
        txt += (recipient.to_single_line + "\n")
        if recipient.ffl
          txt += (recipient.ffl.to_single_line + "\n")
        end
        recipient.items.each do |item|
          txt += (item.to_single_line + "\n")
        end
        txt += recipient.trailer + "\n"
      end
      txt += footer
    end

    def submit!
      connect(@credentials) do |ftp|
        ftp.chdir(RsrGroup.config.submission_dir)
        io = StringIO.new(to_txt)
        begin
          ftp.storlines("STOR " + filename, io)
        ensure
          io.close
        end
      end
    end

    private

    def customer_number
      credentials[:username]
    end

    def items
      recipients.map(&:items).flatten.compact
    end

  end
end
