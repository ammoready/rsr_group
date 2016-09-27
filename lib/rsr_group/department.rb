module RsrGroup
  class Department

    NAMES = {
      '01' => 'Handguns',
      '02' => 'Used Handguns',
      '03' => 'Used Long Guns',
      '04' => 'Tasers',
      '05' => 'Sporting Long Guns',
      '06' => 'SOTS',
      '07' => 'Black Powder Firearms',
      '08' => 'Scopes',
      '09' => 'Scope Mounts',
      '10' => 'Magazines',
      '11' => 'Grips/Pads/Stocks',
      '12' => 'Soft Gun Cases',
      '13' => 'Misc. Accessories',
      '14' => 'Holsters/Pouches',
      '15' => 'Reloading Equipment',
      '16' => 'Black Powder Accessories',
      '17' => 'Closeout Accessories',
      '18' => 'Ammunition',
      '19' => 'Survival Supplies',
      '20' => 'Flashlights & Batteries',
      '21' => 'Cleaning Equipment',
      '22' => 'Airguns',
      '23' => 'Knives',
      '24' => 'High Capacity Magazines',
      '25' => 'Safes/Security',
      '26' => 'Safety/Protection',
      '27' => 'Non-Lethal Defense',
      '28' => 'Binoculars',
      '29' => 'Spotting Scopes',
      '30' => 'Sights/Lasers/Lights',
      '31' => 'Optical Accessories',
      '32' => 'Barrels/Choke Tubes',
      '33' => 'Clothing',
      '34' => 'Parts',
      '35' => 'Slings/Swivels',
      '36' => 'Electronics',
      '37' => 'Not Used',
      '38' => 'Books/Software',
      '39' => 'Targets',
      '40' => 'Hard gun Cases',
      '41' => 'Upper Receivers/Conv Kits',
      '42' => 'SBR Uppers',
      '43' => 'Upper/Conv Kits-High Cap',
    }

    def initialize(id)
      @id = id
      raise RsrGroup::UnknownDepartment.new("Invalid ID: valid ID range: #{NAMES.keys.first}-#{NAMES.keys.last}") unless NAMES.keys.include?(@id)
    end

    def name
      NAMES[@id]
    end

  end
end
