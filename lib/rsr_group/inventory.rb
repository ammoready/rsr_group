module RsrGroup
  class Inventory < Base

    KEYDEALER_DIR = 'keydealer'.freeze
    INVENTORY_DIR = 'ftpdownloads'.freeze
    QTY_FILENAME  = 'IM-QTY-CSV.csv'.freeze
    MAP_FILENAME  = 'retail-map.csv'.freeze
    INVENTORY_FILENAME = 'rsrinventory-new.txt'.freeze
    KEYDEALER_FILENAME = 'rsrinventory-keydlr-new.txt'.freeze

    DEFAULT_SMART_OPTS = {
      chunk_size: 100,
      convert_values_to_numeric: false,
      col_sep: ";",
      quote_char: "|",
      headers_in_file: false,
      user_provided_headers: [
        :item_identifier, :upc, :short_description, :department_number, :manufacturer_id, :retail_price,
        :price, :weight, :quantity, :model, :manufacturer, :mfg_number, :allocated_closeout_deleted, :long_description,
        :image_name, 51.times.map { |i| "state_#{i}".to_sym }, :ships_ground_only, :signature_required, :blocked_from_drop_ship,
        :date_entered, :map_price, :image_disclaimer, :length, :width, :height, :null
      ].flatten,
      remove_unmapped_keys: true,
    }

    def initialize(options = {})
      requires!(options, :username, :password)

      @options = options
    end

    def self.all(chunk_size, options = {}, &block)
      requires!(options, :username, :password)
      new(options).all(chunk_size, &block)
    end

    def all(chunk_size, &block)
      connect(@options) do |ftp|
        tempfile = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(KEYDEALER_FILENAME, tempfile.path)
        else
          ftp.chdir(INVENTORY_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(INVENTORY_FILENAME, tempfile.path)
        end

        SmarterCSV.process(tempfile, DEFAULT_SMART_OPTS.merge(chunk_size: chunk_size)) do |chunk|
          yield(chunk)
        end

        tempfile.unlink
        ftp.close
      end
    end

  end
end
