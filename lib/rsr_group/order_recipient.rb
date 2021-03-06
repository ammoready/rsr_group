module RsrGroup
  class OrderRecipient < Base

    def initialize(options = {})
      requires!(options, :order_identifier, :shipping_name, :address_one, :city, :state, :zip)

      @options = options
      @order_identifier = options[:order_identifier]
    end

    def to_single_line
      [
        @order_identifier,
        LINE_TYPES.key(:order_header),
        @options[:shipping_name],
        @options[:attn],
        @options[:address_one],
        @options[:address_two],
        @options[:city],
        @options[:state],
        @options[:zip],
        (@options[:phone].nil? ? '' : @options[:phone].gsub(/\D/, '')),
        (@options[:email].nil? ? 'N' : 'Y'),
        @options[:email],
        RsrGroup.config.vendor_email,
        nil
      ].join(";")
    end

  end
end
