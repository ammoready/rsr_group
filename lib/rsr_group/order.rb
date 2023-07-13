module RsrGroup
  # To submit an order:
  #
  # * Instantiate a new Order, passing in `:merchant_number`, `:username`, `:password`, `:sequence_number`, and `:identifier`
  # * Call {#add_recipient}
  # * Call {#add_item} for each item on the order
  # * Call {#submit!} to send the order
  class Order < Base

    class ResponseStruct < Struct.new(:success, :message, :data)

      # Simple response object to pass along success/falure/messages of any process
      # Usage:
      #   response = ResponseStruct.new(true)
      #   response = ResponseStruct.new(false, "You did the wrong thing")
      #   response = ResponseStruct.new(true, nil, { result: 200 })

      alias success? success
    end

    # @param [Hash] options
    # @option options [String]  :merchant_number *required*
    # @option options [Integer] :sequence_number *required*
    # @option options [String]  :username        *required*
    # @option options [String]  :password        *required*
    # @option options [String]  :identifier      *required*
    def initialize(options = {})
      requires!(options, :merchant_number, :sequence_number, :username, :password, :identifier)

      @credentials     = options.select { |k, v| [:username, :password].include?(k) }
      @identifier      = options[:identifier]
      @merchant_number = "%05d" % options[:merchant_number] # Leading zeros are required
      @sequence_number = "%04d" % options[:sequence_number] # Leading zeros are required
      @timestamp       = Time.now.in_time_zone('Eastern Time (US & Canada)').strftime("%Y%m%d")
      @items           = []
    end

    # @param [Hash] shipping_info
    # @option shipping_info [String] :shipping_name *required*
    # @option shipping_info [String] :attn
    # @option shipping_info [String] :address_one   *required*
    # @option shipping_info [String] :address_two
    # @option shipping_info [String] :city          *required*
    # @option shipping_info [String] :state         *required*
    # @option shipping_info [String] :zip           *required*
    # @option shipping_info [String] :phone
    # @option shipping_info [String] :email
    #
    # @param [Hash] ffl_options optional
    # @option ffl_options [String] :license_number *required*
    # @option ffl_options [String] :name           *required*
    # @option ffl_options [String] :zip            *required*
    def add_recipient(shipping_info, ffl_options = {})
      requires!(shipping_info, :shipping_name, :address_one, :city, :state, :zip)

      @recipient = OrderRecipient.new(shipping_info.merge(order_identifier: @identifier))

      if ffl_options && ffl_options.any?
        @ffl = OrderFFL.new(ffl_options.merge(order_identifier: @identifier))
      end
    end

    # @param [Hash] item
    # @option item [String]  :rsr_stock_number *required*
    # @option item [Integer] :quantity         *required*
    # @option item [String]  :shipping_carrier *required*
    # @option item [String]  :shipping_method  *required*
    def add_item(item = {})
      requires!(item, :rsr_stock_number, :quantity, :shipping_carrier, :shipping_method)

      @items << OrderDetail.new(item.merge(order_identifier: @identifier))
    end

    def filename
      name = ["EORD", @merchant_number, @timestamp, @sequence_number].join("-")
      [name, ".txt"].join
    end

    def to_txt
      raise "Recipient is required!" unless @recipient
      raise "Items are required!" unless @items.length > 0

      txt = header + "\n"
      txt += @recipient.to_single_line + "\n"
      if @ffl
        txt += (@ffl.to_single_line + "\n")
      end
      @items.each do |item|
        txt += (item.to_single_line + "\n")
      end
      txt += order_trailer + "\n"
      txt += footer
    end

    def submit!
      connect(@credentials) do |ftp|
        ftp.chdir(RsrGroup.config.submission_dir)
        io = StringIO.new(to_txt)
        begin
          ftp.storlines("STOR " + filename, io)
          success = ftp.nlst.include?(filename)
          @response = ResponseStruct.new(success, nil, modified: ftp.mtime(filename), size: ftp.size(filename))
        ensure
          io.close
        end
        ftp.close
      end
      @response || ResponseStruct.new(false)
    rescue Net::FTPPermError => e
      return ResponseStruct.new(false, e.message.chomp)
    end

    private

    def header
      ["FILEHEADER", LINE_TYPES.key(:file_header), @merchant_number, @timestamp, @sequence_number].join(";")
    end

    def footer
      # NOTE: The 'Number of Orders in File' datum is hard-coded to 1
      # For our purposes, only 1 recipient can ever be allowed in an RSR order
      ["FILETRAILER", LINE_TYPES.key(:file_trailer), '00001'].join(";")
    end

    def order_trailer
      [@identifier, LINE_TYPES.key(:order_trailer), ("%07d" % total_quantity)].join(";")
    end

    def total_quantity
      @items.map { |x| x.quantity.to_i }.inject(0, :+)
    end

  end
end
