module RsrGroup
  class Catalog < Base

    KEYDEALER_DIR      = 'keydealer'.freeze
    INVENTORY_DIR      = 'ftpdownloads'.freeze
    INVENTORY_FILENAME = 'rsrinventory-new.txt'.freeze
    KEYDEALER_FILENAME = 'rsrinventory-keydlr-new.txt'.freeze

    def initialize(options = {})
      requires!(options, :username, :password)

      @options = options
    end

    def self.all(chunk_size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def all(chunk_size, &block)
      connect(@options) do |ftp|
        begin
          chunker      = RsrGroup::Chunker.new(chunk_size)
          csv_tempfile = Tempfile.new

          if ftp.nlst.include?(KEYDEALER_DIR)
            ftp.chdir(KEYDEALER_DIR)
            ftp.getbinaryfile(KEYDEALER_FILENAME, csv_tempfile.path)
          else
            ftp.chdir(INVENTORY_DIR)
            ftp.getbinaryfile(INVENTORY_FILENAME, csv_tempfile.path)
          end

          chunker.total_count = File.readlines(csv_tempfile).size

          CSV.readlines(csv_tempfile, col_sep: ';', quote_char: "\x00").to_enum.with_index(1).each do |row, current_line|
            if chunker.is_full?
              yield(chunker.chunk)

              chunker.reset
            elsif chunker.is_complete?
              yield(chunker.chunk)

              break
            else
              chunker.add(process_row(row))
            end
          end
        end

        csv_tempfile.unlink
        ftp.close
      end
    end

    private

    def sanitize(data)
      return data unless data.is_a?(String)
      data.strip
    end

    def process_row(row)
      {
        upc:                sanitize(row[1]),
        item_identifier:    sanitize(row[0]),
        name:               sanitize(row[2]),
        short_description:  sanitize(row[2]),
        category:           row[3].nil? ? row[3] : RsrGroup::Department.new(row[3]).name,
        brand:              sanitize(row[10]),
        map_price:          sanitize(row[70]),
        price:              sanitize(row[6]),
        quantity:           (Integer(sanitize(row[8])) rescue 0),
        mfg_number:         sanitize(row[11]),
        weight:             sanitize(row[7]),
        long_description:   sanitize(row[13]),
        features: {
          model:            sanitize(row[9]),
          shipping_length:  sanitize(row[74]),
          shipping_width:   sanitize(row[75]),
          shipping_height:  sanitize(row[76])
        }
      }
    end

  end
end
