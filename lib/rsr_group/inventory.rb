module RsrGroup
  class Inventory < Base

    KEYDEALER_DIR = 'keydealer'.freeze
    INVENTORY_DIR = 'ftpdownloads'.freeze
    QTY_FILENAME  = 'IM-QTY-CSV.csv'.freeze
    MAP_FILENAME  = 'retail-map.csv'.freeze
    INVENTORY_FILENAME = 'rsrinventory-new.txt'.freeze
    KEYDEALER_FILENAME = 'rsrinventory-keydlr-new.txt'.freeze

    DEFAULT_SMART_OPTS = {
      chunk_size: 500,
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

    def self.get_quantity_file(options = {})
      requires!(options, :username, :password)
      new(options).get_quantity_file
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
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(KEYDEALER_FILENAME, tempfile.path)
        else
          ftp.chdir(INVENTORY_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(INVENTORY_FILENAME, tempfile.path)
        end

        SmarterCSV.process(tempfile, DEFAULT_SMART_OPTS) do |chunk|
          chunk.each do |item|
            yield(item)
          end
        end

        tempfile.unlink
        ftp.close
      end
    end

    def get_quantity_file
      connect(@options) do |ftp|
        quantity_tempfile = Tempfile.new
        tempfile          = Tempfile.new(['quantity-', '.csv'])

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(QTY_FILENAME, quantity_tempfile.path)
        else
          ftp.chdir(INVENTORY_DIR)
          # Pull from the FTP and save as a temp file
          ftp.getbinaryfile(QTY_FILENAME, quantity_tempfile.path)
        end

        ftp.close

        SmarterCSV.process(quantity_tempfile.open, {
          chunk_size: 100,
          force_utf8: true,
          convert_values_to_numeric: false,
          user_provided_headers: [:item_identifier, :quantity]
        }) do |chunk|
          chunk.each do |item|
            tempfile.puts("#{item[:item_identifier]},#{item[:quantity]}")
          end
        end

        quantity_tempfile.unlink
        tempfile.path
      end
    end

    def quantity(&block)
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

        SmarterCSV.process(tempfile, DEFAULT_SMART_OPTS) do |chunk|
          chunk.each do |item|
            item = Hash[*item.select {|k,v| [:item_identifier, :quantity].include?(k)}.flatten]

            yield(item)
          end
        end

        tempfile.unlink
        ftp.close
      end
    end

  end
end
