require 'spec_helper'

describe RsrGroup::ResponseFile do

  let(:credentials) { { username: "login", password: "password" } }

  describe 'dynamic methods' do
    describe "error?" do
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: "EERR-RSRGP-12345-20161117-0001.txt")) }

      it { expect(response_file.error?).to be(true) }
    end

    describe "confirmation?" do
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: "ECONF-RSRGP-12345-20161117-0001.txt")) }

      it { expect(response_file.confirmation?).to be(true) }
    end

    describe "shipping?" do
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: "ESHIP-RSRGP-12345-20161117-0001.txt")) }

      it { expect(response_file.shipping?).to be(true) }
    end
  end

  describe '.all' do
    let(:all) { RsrGroup::ResponseFile.all(credentials) }

    before do
      ftp = instance_double("Net::FTP", :passive= => true)
      allow(ftp).to receive(:chdir).with("eo/outgoing") { true }
      allow(ftp).to receive(:nlst).with("*.txt") { ["file1.txt", "file2.txt"] }
      allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
    end

    it { expect(all.length).to eq(2) }
  end

  describe '#content' do
    let(:filename) { "EERR-RSRGP-12345-20161117-0001.txt" }
    let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: filename)) }

    before do
      ftp = instance_double("Net::FTP", :passive= => true)
      allow(ftp).to receive(:chdir).with("eo/outgoing") { true }
      allow(ftp).to receive(:gettextfile).with(filename, nil) { test_eerr_file }
      allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
      response_file.content
    end

    it { expect(response_file.instance_variable_get(:@content).length).to be > 0 }
  end

  describe '#response_type' do
    context "EERR" do
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: "EERR-RSRGP-12345-20161117-0001.txt")) }
      
      it { expect(response_file.response_type).to eq("Error") }
    end

    context "ECONF" do
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: "ECONF-RSRGP-12345-20161117-0001.txt")) }

      it { expect(response_file.response_type).to eq("Confirmation") }
    end

    context "ESHIP" do
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: "ESHIP-RSRGP-12345-20161117-0001.txt")) }
      
      it { expect(response_file.response_type).to eq("Shipping") }
    end
  end

  describe '#to_json' do
    context "EERR" do
      let(:filename) { "EERR-RSRGP-12345-20161117-0001.txt" }
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: filename)) }
      let(:expectation) {
        {
          response_type: "Error",
          identifier:    "4000-1000",
          errors:  [
            { identifier: "4000-1000",
              line_type: 'order_detail',
              quantity: '1',
              stock_id: "MPIMAG485GRY",
              shipping_carrier: "USPS",
              shipping_method: "Priority",
              error_code: "20005",
              message: "Invalid shipping method" },
            { identifier: "4000-1000",
              line_type: 'order_detail',
              quantity: '1',
              stock_id: "CS20NPKZ",
              shipping_carrier: "USPS",
              shipping_method: "Priority",
              error_code: "20005",
              message: "Invalid shipping method" },
          ]
        }
      }

      before do
        ftp = instance_double("Net::FTP", :passive= => true)
        allow(ftp).to receive(:chdir).with("eo/outgoing") { true }
        allow(ftp).to receive(:gettextfile).with(filename, nil) { test_eerr_file }
        allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
      end

      it { expect(response_file.to_json).to eq(expectation) }
    end

    context "ECONF" do
      let(:filename) { "ECONF-RSRGP-12345-20161117-0002.txt" }
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: filename)) }
      let(:expectation) {
        { response_type:    "Confirmation",
          identifier:       "4000-1020",
          rsr_order_number: "17222",
          details: [
            { identifier: "4000-1020",
              line_type: 'confirmation_detail',
              committed: '1',
              ordered: '1',
              stock_id: "CS20NPKZ" },
            { identifier: "4000-1020",
              line_type: 'confirmation_detail',
              committed: '0',
              ordered: '1',
              stock_id: "MPIMAG485GRY" }
          ]
        }
      }

      before do
        ftp = instance_double("Net::FTP", :passive= => true)
        allow(ftp).to receive(:chdir).with("eo/outgoing") { true }
        allow(ftp).to receive(:gettextfile).with(filename, nil) { test_econf_file }
        allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
      end

      it { expect(response_file.to_json).to eq(expectation) }
    end

    context "ESHIP" do
      let(:filename) { "ESHIP-RSRGP-12345-20161117-0002.txt" }
      let(:response_file) { RsrGroup::ResponseFile.new(credentials.merge(filename: filename)) }
      let(:expectation) {
        {
          response_type:    "Shipping",
          identifier:       "5000-2000",
          rsr_order_number: "99999",
          details: [
            { identifier: "5000-2000",
              line_type: 'shipping_header',
              ship_to_name: "Bellatrix",
              shipping_carrier: "UPS",
              shipping_method: "Grnd",
              date_shipped: '20161117',
              handling_fee: "0",
              rsr_order_number: "58776",
              shipping_cost: "800",
              tracking_number: "1Z7539320314612868"},
            { identifier: "5000-2000",
              line_type: 'shipping_detail',
              stock_id: "CS20NPKZ",
              ordered: '1',
              shipped: '1' },
            { identifier: "5000-2000",
              line_type: 'shipping_detail',
              stock_id: "MPIMAG485GRY",
              ordered: '1',
              shipped: '1' }
          ],
        }
      }

      before do
        ftp = instance_double("Net::FTP", :passive= => true)
        allow(ftp).to receive(:chdir).with("eo/outgoing") { true }
        allow(ftp).to receive(:gettextfile).with(filename, nil) { test_eship_file }
        allow(Net::FTP).to receive(:open).with("ftp.host.com", "login", "password") { |&block| block.call(ftp) }
      end

      it { expect(response_file.to_json).to eq(expectation) }
    end
  end

end
