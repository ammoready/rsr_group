module RsrGroup
  class Catalog < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def all
      items = []

      connect(@options) do |ftp|
        begin
          tempfile = Tempfile.new

          if ftp.nlst.include?(KEYDEALER_DIR)
            ftp.chdir(KEYDEALER_DIR)
            ftp.getbinaryfile(KEYDEALER_CATALOG_FILENAME, tempfile.path)
          else
            ftp.chdir(DEFAULT_DIR)
            ftp.getbinaryfile(DEFAULT_CATALOG_FILENAME, tempfile.path)
          end
          ftp.close

          CSV.foreach(tempfile, { col_sep: ';', quote_char: "\x00" }).each do |row|
            item = process_row(row)

            if !row[12].nil? && row[12].to_sym.eql?(:Allocated)
              item[:quantity] = 0
            end

            items << item
          end
        end

        tempfile.unlink
      end

      items
    end

    private

    def sanitize(data)
      return data unless data.is_a?(String)
      data.strip
    end

    def process_row(row)
      category_name = row[3].nil? ? nil : RsrGroup::Department.new(row[3]).name

      {
        upc:             sanitize(row[1]),
        item_identifier: sanitize(row[0]),
        name:            sanitize(row[2]),
        model:           sanitize(row[9]),
        category:        category_name,
        brand:           sanitize(row[10]),
        msrp:            sanitize(row[5]),
        price:           sanitize(row[6]),
        map_price:       sanitize(row[70]),
        quantity:        (Integer(sanitize(row[8])) rescue 0),
        mfg_number:      sanitize(row[11]),
        weight:          sanitize(row[7]),
        short_description: sanitize(row[2]),
        long_description:  sanitize(row[13]),
        features: {
          shipping_length: sanitize(row[74]),
          shipping_width:  sanitize(row[75]),
          shipping_height: sanitize(row[76])
        }
      }
    end

  end
end
