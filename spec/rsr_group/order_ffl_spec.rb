require 'spec_helper'

describe RsrGroup::OrderFFL do

  let(:order_ffl) {
    RsrGroup::OrderFFL.new({
      order_identifier: '100-444',
      licence_number: 'aa-bb-01-cc',
      name: 'Balrog',
      zip: '22122',
      end_customer_name: 'Gimlee',
      end_customer_phone: '555',
    })
  }

  describe '#initialize' do 
    it { expect(order_ffl.order_identifier).to eq('100-444') }
  end

  describe '#to_single_line' do
    it { expect(order_ffl.to_single_line).to eq('100-444;11;aa-bb-01-cc;Balrog;22122;Gimlee;555') }
  end

end
