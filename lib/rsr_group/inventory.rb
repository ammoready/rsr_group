module RsrGroup
  class Inventory < Base

    # This corresponds with the 'rsrinventory-new.txt' and 'rsrinventory-keydlr-new.txt' files 
    # and the +DEFAULT_CATALOG_FILENAME+ and +KEYDEALER_CATALOG_FILENAME+ constants
    DEFAULT_CATALOG_SMART_OPTS = {
      chunk_size: 500,
      convert_values_to_numeric: false,
      col_sep: ';',
      quote_char: '|',
      headers_in_file: false,
      user_provided_headers: [
        :item_identifier, :upc, :short_description, :department_number, :manufacturer_id, :retail_price,
        :price, :weight, :quantity, :model, :manufacturer, :mfg_number, :allocated_closeout_deleted, :long_description,
        :image_name, 51.times.map { |i| "state_#{i}".to_sym }, :ships_ground_only, :signature_required, 
        :blocked_from_drop_ship, :date_entered, :map_price, :image_disclaimer, :length, :width, :height, :null
      ].flatten,
      remove_unmapped_keys: true,
    }

    # This corresponds with the 'IM-QTY-CSV.csv' file and the +QTY_FILENAME+ constant
    DEFAULT_QUANTITY_SMART_OPTS = {
      chunk_size: 2000,
      convert_values_to_numeric: false,
      col_sep: ',',
      headers_in_file: false,
      user_provided_headers: [
        :item_identifier,
        :quantity,
      ]
    }

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.quantity(options = {}, &block)
      requires!(options, :username, :password)
      new(options).quantity &block
    end

    def self.all(options = {}, &block)
      requires!(options, :username, :password)
      new(options).all &block
    end

    def all(&block)
      connect(@options) do |ftp|
        tempfile = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
          # Pull from the FTP and save to a tempfile
          ftp.getbinaryfile(KEYDEALER_CATALOG_FILENAME, tempfile.path)
        else
          ftp.chdir(DEFAULT_DIR)
          # Pull from the FTP and save to a tempfile
          ftp.getbinaryfile(DEFAULT_CATALOG_FILENAME, tempfile.path)
        end
        ftp.close

        SmarterCSV.process(tempfile, DEFAULT_CATALOG_SMART_OPTS) do |chunk|
          chunk.each do |item|
            if !item[:allocated_closeout_deleted].nil? && item[:allocated_closeout_deleted].to_sym.eql?(:Allocated)
              item[:quantity] = 0
            else
              item[:quantity] = item[:quantity].to_i
            end

            yield(item)
          end
        end

        tempfile.unlink
      end
    end

    # Parse through the 'IM-QTY-CSV.csv' file
    def quantity(&block)
      connect(@options) do |ftp|
        tempfile = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(QTY_FILENAME, tempfile.path)
        else
          ftp.chdir(DEFAULT_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(QTY_FILENAME, tempfile.path)
        end
        ftp.close

        SmarterCSV.process(tempfile, DEFAULT_QUANTITY_SMART_OPTS) do |chunk|
          chunk.each do |item|
            item[:quantity] = item[:quantity].to_i
            yield(item)
          end
        end

        tempfile.unlink
      end
    end

  end
end
