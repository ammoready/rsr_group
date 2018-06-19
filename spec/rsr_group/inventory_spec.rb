require 'spec_helper'

describe RsrGroup::Inventory do

  let(:ftp) { instance_double('Net::FTP', :passive= => true, :debug_mode= => true) }

  before do
    allow(Net::FTP).to receive(:open).with('ftp.host.com', 'login', 'password') { |&block| block.call(ftp) }
  end

  describe '.map_prices' do
    let(:execution) { RsrGroup::Inventory.map_prices(username: 'login', password: 'password') }
    let(:expectation) do
      [
        { stock_number: 'PRODUCT1', map_price: '0000838.85'},
        { stock_number: 'PRODUCT2', map_price: '0000038.90'},
        { stock_number: 'PRODUCT3', map_price: '0000199.00'},
        { stock_number: 'PRODUCT4', map_price: '0000838.85'},
      ]
    end

    before do
      allow(ftp).to receive(:nlst) { ['ftpdownloads'] }
      allow(ftp).to receive(:chdir).with('ftpdownloads') { true }
      allow(ftp).to receive(:gettextfile).with('retail-map.csv', nil).
        and_yield(sample_map_prices_csv.lines[0]).
        and_yield(sample_map_prices_csv.lines[1]).
        and_yield(sample_map_prices_csv.lines[2]).
        and_yield(sample_map_prices_csv.lines[3])
      allow(ftp).to receive(:close) { nil }
    end

    xit { expect(execution).to eq(expectation) }
  end

end
