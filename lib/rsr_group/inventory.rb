module RsrGroup
  class Inventory < Base

    KEYDEALER_DIR      = 'keydealer'.freeze
    INVENTORY_DIR      = 'ftpdownloads'.freeze
    INVENTORY_FILENAME = 'rsrinventory-new.txt'.freeze
    KEYDEALER_FILENAME = 'rsrinventory-keydlr-new.txt'.freeze
    QTY_FILENAME       = 'IM-QTY-CSV.csv'.freeze
    MAP_FILENAME       = 'retail-map.csv'.freeze

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def self.process_as_chunks(size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).process_as_chunks(size, &block)
    end

    def self.map_prices(options = {})
      requires!(options, :username, :password)
      new(options).map_prices
    end

    def self.map_prices_as_chunks(size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).map_prices_as_chunks(size, &block)
    end

    def self.quantities(options = {})
      requires!(options, :username, :password)
      new(options).quantities
    end

    def self.quantities_as_chunks(size = 15, options = {}, &block)
      requires!(options, :username, :password)
      new(options).quantities_as_chunks(size, &block)
    end

    def all
      items = []

      connect(@options) do |ftp|
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
          lines = ftp.gettextfile(KEYDEALER_FILENAME, nil)
        else
          ftp.chdir(INVENTORY_DIR)
          lines = ftp.gettextfile(INVENTORY_FILENAME, nil)
        end

        # Use a zero-byte char as `quote_char` since the data has no quote character.
        CSV.parse(lines, col_sep: ';', quote_char: "\x00") do |row|
          items << {
            stock_number: sanitize(row[0]),
            upc: sanitize(row[1]),
            description: sanitize(row[2]),
            department: row[3].nil? ? row[3] : RsrGroup::Department.new(row[3]),
            manufacturer_id: sanitize(row[4]),
            retail_price: sanitize(row[5]),
            regular_price: sanitize(row[6]),
            weight: sanitize(row[7]),
            quantity: (Integer(sanitize(row[8])) rescue 0),
            model: sanitize(row[9]),
            manufacturer_name: sanitize(row[10]),
            manufacturer_part_number: sanitize(row[11]),
            allocated_closeout_deleted: sanitize(row[12]),
            description_full: sanitize(row[13]),
            image_name: sanitize(row[14]),
            ground_shipping_only: row[68] == 'Y',
            adult_signature_required: row[69] == 'Y',
            blocked_from_drop_ship: row[70] == 'Y',
            date_entered: row[71].nil? ? row[71] : Date.strptime(row[71], '%Y%m%d'),
            retail_map: sanitize(row[72]),
            image_disclaimer: row[73] == 'Y',
            shipping_length: sanitize(row[74]),
            shipping_width: sanitize(row[75]),
            shipping_height: sanitize(row[76]),
          }
        end

        ftp.close
      end

      items
    end

    def process_as_chunks(size, &block)
      connect(@options) do |ftp|
        chunker       = RsrGroup::Chunker.new(size)
        temp_csv_file = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)

          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(KEYDEALER_FILENAME, temp_csv_file.path)
        else
          ftp.chdir(INVENTORY_DIR)

          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(INVENTORY_FILENAME, temp_csv_file.path)
        end

        # total_count is the number of lines in the file
        chunker.total_count = File.readlines(temp_csv_file).size

        CSV.readlines(temp_csv_file, col_sep: ';', quote_char: "\x00").to_enum.with_index(1).each do |row, current_line|

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

        temp_csv_file.unlink
        ftp.close
      end
    end

    def map_prices
      rows = []

      connect(@options) do |ftp|
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
        else
          ftp.chdir(INVENTORY_DIR)
        end

        ftp.gettextfile(MAP_FILENAME, nil) do |line|
          points = line.split(',').map(&:rstrip)
          rows << {
            stock_number: points[0],
            map_price:    points[1],
          }
        end

        ftp.close
      end

      rows
    end

    def map_prices_as_chunks(size, &block)
      connect(@options) do |ftp|
        chunker       = RsrGroup::Chunker.new(size)
        temp_csv_file = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
        else
          ftp.chdir(INVENTORY_DIR)
        end

        # Pull from the FTP and save as a temp file
        ftp.getbinaryfile(MAP_FILENAME, temp_csv_file.path)

        # total_count is hte number of lines in the file
        chunker.total_count = File.readlines(temp_csv_file).size

        CSV.readlines(temp_csv_file).each do |row|
          if chunker.is_full?
            yield(chunker.chunk)

            chunker.reset
          elsif chunker.is_complete?
            yield(chunker.chunk)

            break
          else
            chunker.add({
              stock_number: row[0].strip,
              map_price:    row[1]
            })
          end
        end

        temp_csv_file.unlink
        ftp.close
      end
    end

    def quantities
      rows = []

      connect(@options) do |ftp|
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
        else
          ftp.chdir(INVENTORY_DIR)
        end

        csv = ftp.gettextfile(QTY_FILENAME, nil)

        CSV.parse(csv) do |row|
          rows << { 
            stock_number: row[0].rstrip,
            quantity: row[1].to_i,
          }
        end

        ftp.close
      end

      rows
    end

    def quantities_as_chunks(size, &block)
      connect(@options) do |ftp|
        chunker       = RsrGroup::Chunker.new(size)
        temp_csv_file = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
        else
          ftp.chdir(INVENTORY_DIR)
        end

        # Pull from the FTP and save as a temp file
        ftp.getbinaryfile(QTY_FILENAME, temp_csv_file.path)

        # total_count is hte number of lines in the file
        chunker.total_count = File.readlines(temp_csv_file).size

        CSV.readlines(temp_csv_file).each do |row|
          if chunker.is_full?
            yield(chunker.chunk)

            chunker.reset
          elsif chunker.is_complete?
            yield(chunker.chunk)

            break
          else
            chunker.add({
              stock_number: row[0].rstrip,
              quantity: row[1].to_i
            })
          end
        end

        temp_csv_file.unlink
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
        stock_number: sanitize(row[0]),
        upc: sanitize(row[1]),
        description: sanitize(row[2]),
        department: row[3].nil? ? row[3] : RsrGroup::Department.new(row[3]),
        manufacturer_id: sanitize(row[4]),
        retail_price: sanitize(row[5]),
        regular_price: sanitize(row[6]),
        weight: sanitize(row[7]),
        quantity: (Integer(sanitize(row[8])) rescue 0),
        model: sanitize(row[9]),
        manufacturer_name: sanitize(row[10]),
        manufacturer_part_number: sanitize(row[11]),
        allocated_closeout_deleted: sanitize(row[12]),
        description_full: sanitize(row[13]),
        image_name: sanitize(row[14]),
        ground_shipping_only: row[68] == 'Y',
        adult_signature_required: row[69] == 'Y',
        blocked_from_drop_ship: row[70] == 'Y',
        date_entered: row[71].nil? ? row[71] : Date.strptime(row[71], '%Y%m%d'),
        retail_map: sanitize(row[72]),
        image_disclaimer: row[73] == 'Y',
        shipping_length: sanitize(row[74]),
        shipping_width: sanitize(row[75]),
        shipping_height: sanitize(row[76]),
      }
    end

  end
end
