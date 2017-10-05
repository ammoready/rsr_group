module RsrGroup
  class Inventory < Base

    KEYDEALER_DIR      = 'keydealer'.freeze
    INVENTORY_DIR      = 'ftpdownloads'.freeze
    QTY_FILENAME       = 'IM-QTY-CSV.csv'.freeze
    MAP_FILENAME       = 'retail-map.csv'.freeze

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
        chunker       = RsrGroup::Chunker.new(chunk_size)
        csv_tempfile  = Tempfile.new

        # Is this a key dealer?
        if ftp.nlst.include?(KEYDEALER_DIR)
          ftp.chdir(KEYDEALER_DIR)
        else
          ftp.chdir(INVENTORY_DIR)
        end

        # Pull from the FTP and save as a temp file
        ftp.getbinaryfile(QTY_FILENAME, csv_tempfile.path)

        # total_count is hte number of lines in the file
        chunker.total_count = File.readlines(csv_tempfile).size

        CSV.readlines(csv_tempfile).each do |row|
          if chunker.is_full?
            yield(chunker.chunk)

            chunker.reset
          elsif chunker.is_complete?
            yield(chunker.chunk)

            break
          else
            chunker.add({
              item_identifier:  row[0].rstrip,
              quantity:         row[1].to_i
            })
          end
        end

        csv_tempfile.unlink
        ftp.close
      end
    end

  end
end
