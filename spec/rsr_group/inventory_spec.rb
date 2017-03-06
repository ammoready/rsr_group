require 'spec_helper'

describe RsrGroup::Inventory do

  describe '.all' do
    let(:execution) { RsrGroup::Inventory.all(username: 'login', password: 'password') }

    before do
      ftp = instance_double('Net::FTP', :passive= => true)
      allow(ftp).to receive(:nlst) { ['ftpdownloads'] }
      allow(ftp).to receive(:chdir).with('ftpdownloads') { true }
      allow(ftp).to receive(:gettextfile).with('rsrinventory-new.txt', nil) { sample_inventory_txt }
      allow(Net::FTP).to receive(:open).with('ftp.host.com', 'login', 'password') { |&block| block.call(ftp) }
      allow(ftp).to receive(:close) { nil }
    end

    it { expect(execution.map { |x| x[:stock_number] }).to eq(["PRODUCT1", "PRODUCT2", "PRODUCT3", "PRODUCT3"]) }
  end

  describe '.quantities' do
    let(:execution) { RsrGroup::Inventory.quantities(username: 'login', password: 'password') }
    let(:expectation) do
      [
        { stock_number: 'PRODUCT1', quantity: 20  },
        { stock_number: 'PRODUCT2', quantity: 10  },
        { stock_number: 'PRODUCT3', quantity: 0   },
        { stock_number: 'PRODUCT4', quantity: 300 }
      ]
    end

    before do
      ftp = instance_double('Net::FTP', :passive= => true)
      allow(ftp).to receive(:nlst) { ['ftpdownloads'] }
      allow(ftp).to receive(:chdir).with('ftpdownloads') { true }
      allow(ftp).to receive(:gettextfile).with('IM-QTY-CSV.csv', nil) { sample_quantity_csv }
      allow(Net::FTP).to receive(:open).with('ftp.host.com', 'login', 'password') { |&block| block.call(ftp) }
      allow(ftp).to receive(:close) { nil }
    end

    it { expect(execution).to eq(expectation) }
  end

end
