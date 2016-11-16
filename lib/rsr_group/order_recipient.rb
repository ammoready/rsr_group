module RsrGroup
  class OrderRecipient < Base

    attr_reader :order_identifier
    attr_accessor :ffl
    attr_accessor :items

    def initialize(options = {})
      requires!(options, :order_identifier, :shipping_name, :address_one, :city, :state, :zip)

      @ffl = options[:ffl]
      @items = options[:items] || []
      @options = options
      @order_identifier = options[:order_identifier]
    end

    def items
      @items ||= []
    end

    def to_single_line
      [
        order_identifier,
        Order::LINE_TYPES.key("order_header"),
        @options[:shipping_name],
        @options[:attn],
        @options[:address_one],
        @options[:address_two],
        @options[:city],
        @options[:state],
        @options[:zip],
        @options[:phone],
        (@options[:email].nil? ? "N" : "Y"),
        @options[:email],
        RsrGroup.config.vendor_email,
        nil
      ].join(";")
    end

    def trailer
      [
        order_identifier,
        Order::LINE_TYPES.key("order_trailer"),
        ("%07d" % quantity_sum)
      ].join(";")
    end

    private

    def quantity_sum
      items.map(&:quantity).map(&:to_i).inject(:+)
    end

  end
end
