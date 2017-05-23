module RsrGroup
  class OrderFFL < Base

    attr_reader :order_identifier

    def initialize(options = {})
      requires!(options, :order_identifier, :licence_number, :name, :zip, :end_customer_name, :end_customer_phone)

      @options = options
      @order_identifier = options[:order_identifier]
    end

    def to_single_line
      [
        order_identifier,
        LINE_TYPES.key(:ffl_dealer),
        @options[:licence_number],
        @options[:name],
        @options[:zip],
        @options[:end_customer_name],
        @options[:end_customer_phone]
      ].join(";")
    end

  end
end
