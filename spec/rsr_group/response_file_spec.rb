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
          identifier:    "1z112z28",
          errors: [
            { code: "20005", message: "Invalid shipping method", stock_id: "MPIMAG485GRY" },
            { code: "20005", message: "Invalid shipping method", stock_id: "CS20NPKZ" }
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
        {
          response_type:    "Confirmation",
          identifier:       "1z112z29",
          rsr_order_number: "17222",
          details: [
            { stock_id: "CS20NPKZ", ordered: 1, committed: 1 }, 
            { stock_id: "MPIMAG485GRY", ordered: 1, committed: 0 },
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
          response_type: "Shipping",
          identifier:    "1z112z29",
          info:          [],
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
  end

end
