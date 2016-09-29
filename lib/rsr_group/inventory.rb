module RsrGroup
  class Inventory < Base

    INVENTORY_DIR = 'ftpdownloads'
    INVENTORY_FILENAME = 'rsrinventory-new.txt'

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
        ftp.chdir(INVENTORY_DIR)

        lines = ftp.gettextfile(INVENTORY_FILENAME, nil)

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
            quantity: sanitize(row[8]),
            model: sanitize(row[9]),
            manufacturer_name: sanitize(row[10]),
            manufacturer_part_number: sanitize(row[11]),
            allocated_closeout_deleted: sanitize(row[12]),
            description_full: sanitize(row[13]),
            image_name: sanitize(row[14]),
            restricted_states: {
              AK: row[15] == 'Y',
              AL: row[16] == 'Y',
              AR: row[17] == 'Y',
              AZ: row[18] == 'Y',
              CA: row[19] == 'Y',
              CO: row[20] == 'Y',
              CT: row[21] == 'Y',
              DC: row[22] == 'Y',
              DE: row[23] == 'Y',
              FL: row[24] == 'Y',
              GA: row[25] == 'Y',
              HI: row[26] == 'Y',
              IA: row[27] == 'Y',
              ID: row[28] == 'Y',
              IL: row[29] == 'Y',
              IN: row[30] == 'Y',
              KS: row[31] == 'Y',
              KY: row[32] == 'Y',
              LA: row[33] == 'Y',
              MA: row[36] == 'Y',
              MD: row[37] == 'Y',
              ME: row[38] == 'Y',
              MI: row[39] == 'Y',
              MN: row[40] == 'Y',
              MO: row[41] == 'Y',
              MS: row[42] == 'Y',
              MT: row[43] == 'Y',
              NC: row[44] == 'Y',
              ND: row[45] == 'Y',
              NE: row[46] == 'Y',
              NH: row[47] == 'Y',
              NJ: row[48] == 'Y',
              NM: row[49] == 'Y',
              NV: row[50] == 'Y',
              NY: row[51] == 'Y',
              OH: row[52] == 'Y',
              OK: row[53] == 'Y',
              OR: row[54] == 'Y',
              PA: row[55] == 'Y',
              RI: row[56] == 'Y',
              SC: row[57] == 'Y',
              SD: row[58] == 'Y',
              TN: row[59] == 'Y',
              TX: row[60] == 'Y',
              UT: row[61] == 'Y',
              VA: row[62] == 'Y',
              VT: row[63] == 'Y',
              WA: row[64] == 'Y',
              WI: row[65] == 'Y',
              WV: row[66] == 'Y',
              WY: row[67] == 'Y',
            },
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

      items
    end

    private

    def sanitize(data)
      return data unless data.is_a?(String)
      data.strip
    end

  end
end
