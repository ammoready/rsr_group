module RsrGroup
  class OrderDetail < Base

    attr_reader :order_identifier
    attr_reader :quantity

    def initialize(options = {})
      requires!(options, :order_identifier, :rsr_stock_number, :quantity, :shipping_carrier, :shipping_method)

      @order_identifier = options[:order_identifier]
      @rsr_stock_number = options[:rsr_stock_number]
      @quantity         = (options[:quantity].is_a?(Integer) ? ("%05d" % options[:quantity]) : options[:quantity])
      @shipping_carrier = options[:shipping_carrier]
      @shipping_method  = options[:shipping_method]
    end

    def to_single_line
      [
        order_identifier,
        LINE_TYPES.key(:order_detail),
        @rsr_stock_number,
        @quantity,
        @shipping_carrier, 
        @shipping_method
      ].join(";")
    end

  end
end
