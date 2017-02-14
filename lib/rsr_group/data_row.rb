module RsrGroup
  class DataRow < Base
  
    attr_reader :committed, :date_shipped, :error_code, :handling_fee,
      :identifier, :licence_number, :line_type, :message, :name, 
      :ordered, :quantity, :stock_id, :ship_to_name, :shipped, 
      :shipping_carrier, :shipping_cost, :shipping_method, 
      :rsr_order_number, :tracking_number, :zip

    def initialize(line, has_errors: false)
      points = line.split(";").map { |point| point.chomp }

      @identifier = points[0]
      @line_type  = LINE_TYPES[points[1]]

      case @line_type
      when :order_header
        get_errors(points[-1]) if has_errors && points[-1] != "00000"
        @ship_to_name = points[2]
        @zip = points[8]
      when :ffl_dealer # 11
        get_errors(points[-1]) if has_errors && points[-1] != "00000"
        @licence_number = points[2]
        @name = points[3]
        @zip  = points[4]
      when :order_detail # 20
        get_errors(points[-1]) if has_errors && points[-1] != "00000"
        @quantity   = points[3].to_i
        @stock_id   = points[2]
        @shipping_carrier = points[4]
        @shipping_method  = SHIPPING_METHODS[points[5]]
      when :confirmation_header # 30
        @rsr_order_number = points[2]
      when :confirmation_detail # 40
        @committed = points[4].to_i
        @ordered   = points[3].to_i
        @stock_id  = points[2]
      when :confirmation_trailer # 50
        @committed = points[3].to_i
        @ordered   = points[2].to_i
      when :shipping_header # 60
        @date_shipped     = Time.parse(points[5])
        @handling_fee     = points[7].to_i.to_s
        @rsr_order_number = points[4]
        @ship_to_name     = points[2]
        @shipping_carrier = points[8]
        @shipping_cost    = points[6].to_i.to_s
        @shipping_method  = points[9]
        @tracking_number  = points[3]
      when :shipping_detail # 70
        @ordered  = points[3].to_i
        @shipped  = points[4].to_i
        @stock_id = points[2]
      when :shipping_trailer # 80
        @ordered = points[2].to_i
        @shipped = points[3].to_i
      when :order_trailer # 90
        @quantity = points[2].to_i
      end
    end

    def to_h
      @to_h ||= Hash[
        instance_variables.map do |name|
          [name.to_s.gsub("@", "").to_sym, instance_variable_get(name)]
        end
      ]
    end

    private

    def get_errors(code)
      @error_code = code
      @message = ERROR_CODES[code]
    end

  end
end