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
        ftp.gettextfile(INVENTORY_FILENAME, nil) do |line|
          fields = line.split(';')
          items << {
            stock_number: fields[0],
            upc: fields[1],
            description: fields[2],
            department: fields[3],
            manufacturer_id: fields[4],
            retail_price: fields[5],
            regular_price: fields[6],
            weight: fields[7],
            quantity: fields[8],
            model: fields[9],
            manufacturer_name: fields[10],
            manufacturer_part_number: fields[11],
            allocated_closeout_deleted: fields[12],
            description_full: fields[13],
            image_name: fields[14],
            restricted_states: {
              AK: fields[15] == 'Y',
              AL: fields[16] == 'Y',
              AR: fields[17] == 'Y',
              AZ: fields[18] == 'Y',
              CA: fields[19] == 'Y',
              CO: fields[20] == 'Y',
              CT: fields[21] == 'Y',
              DC: fields[22] == 'Y',
              DE: fields[23] == 'Y',
              FL: fields[24] == 'Y',
              GA: fields[25] == 'Y',
              HI: fields[26] == 'Y',
              IA: fields[27] == 'Y',
              ID: fields[28] == 'Y',
              IL: fields[29] == 'Y',
              IN: fields[30] == 'Y',
              KS: fields[31] == 'Y',
              KY: fields[32] == 'Y',
              LA: fields[33] == 'Y',
              MA: fields[36] == 'Y',
              MD: fields[37] == 'Y',
              ME: fields[38] == 'Y',
              MI: fields[39] == 'Y',
              MN: fields[40] == 'Y',
              MO: fields[41] == 'Y',
              MS: fields[42] == 'Y',
              MT: fields[43] == 'Y',
              NC: fields[44] == 'Y',
              ND: fields[45] == 'Y',
              NE: fields[46] == 'Y',
              NH: fields[47] == 'Y',
              NJ: fields[48] == 'Y',
              NM: fields[49] == 'Y',
              NV: fields[50] == 'Y',
              NY: fields[51] == 'Y',
              OH: fields[52] == 'Y',
              OK: fields[53] == 'Y',
              OR: fields[54] == 'Y',
              PA: fields[55] == 'Y',
              RI: fields[56] == 'Y',
              SC: fields[57] == 'Y',
              SD: fields[58] == 'Y',
              TN: fields[59] == 'Y',
              TX: fields[60] == 'Y',
              UT: fields[61] == 'Y',
              VA: fields[62] == 'Y',
              VT: fields[63] == 'Y',
              WA: fields[64] == 'Y',
              WI: fields[65] == 'Y',
              WV: fields[66] == 'Y',
              WY: fields[67] == 'Y',
            },
            ground_shipping_only: fields[68] == 'Y',
            adult_signature_required: fields[69] == 'Y',
            blocked_from_drop_ship: fields[70] == 'Y',
            date_entered: fields[71],
            retail_map: fields[72],
            image_disclaimer: fields[73] == 'Y',
            shipping_length: fields[74],
            shipping_width: fields[75],
            shipping_height: fields[76],
          }
        end
      end

      items
    end

  end
end
