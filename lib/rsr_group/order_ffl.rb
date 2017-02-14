module RsrGroup
  class OrderFFL < Base

    attr_reader :order_identifier

    def initialize(options = {})
      requires!(options, :order_identifier, :licence_number, :name, :zip)

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
      ].join(";")
    end

  end
end