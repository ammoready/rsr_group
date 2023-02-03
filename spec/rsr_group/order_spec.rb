require 'spec_helper'

describe RsrGroup::Order do

  before do
    now_double = double()
    allow(now_double).to receive(:strftime).with("%Y%m%d") { "20161212" }
    allow(Time).to receive(:now).and_return(now_double)
  end

  let(:basic_order) { 
    RsrGroup::Order.new({
      merchant_number: "4444",
      identifier: "1000-400",
      sequence_number: 1,
      username: "12345",
      password: "kittycat"
    })
  }

  describe '#initialize' do
    it { expect(basic_order.nil?).to be(false) }
    it { expect(basic_order.instance_variable_get(:@timestamp)).to eq('20161212') }
    it { expect(basic_order.instance_variable_get(:@merchant_number)).to eq("04444") }
    it { expect(basic_order.instance_variable_get(:@sequence_number)).to eq("0001") }
  end

  describe '#add_recipient' do
    before do
      basic_order.add_recipient({
        shipping_name: 'Hugo',
        address_one:   '123 Elf Lane',
        city: 'Sunnyville',
        state: 'SC',
        zip: '29600'
      })
    end

    it { expect(basic_order.instance_variable_get(:@recipient)).to be_a(RsrGroup::OrderRecipient) }
  end

  describe '#add_item' do
    before do
      basic_order.add_item({
        rsr_stock_number: "MPIMAG485GRY",
        quantity: 1,
        shipping_carrier: "USPS",
        shipping_method: "PRIO",
      })
    end

    it { expect(basic_order.instance_variable_get(:@items)).to be_a(Array) }
    it { expect(basic_order.instance_variable_get(:@items)[0]).to be_a(RsrGroup::OrderDetail) }
  end

  describe '#filename' do
    it { expect(basic_order.filename).to eq('EORD-04444-20161212-0001.txt') }
  end

  describe "#to_txt" do
    let(:order) { 
      RsrGroup::Order.new({
        merchant_number: "12345",
        identifier: "1000-400",
        sequence_number: 1,
        username: "12345",
        password: "kittycat"
      })
    }

    before do
      order.add_recipient({
        shipping_name: 'Bellatrix',
        address_one: '123 Winchester Ave',
        city: 'Happyville',
        state: 'CA',
        zip: '12345',
        phone: '(888) 999-000',
        email: 'email@example.com'
      }, {
        license_number: 'aa-bb-01-cc',
        name: 'Balrog',
        zip: '22122',
        end_customer_name: 'Gimlee',
        end_customer_phone: '555',
      })
      order.add_item({
        rsr_stock_number: "BRS34002",
        quantity: 2,
        shipping_carrier: "USPS",
        shipping_method: "PRIO",
      })
      order.add_item({
        rsr_stock_number: "AUT12KT",
        quantity: 1,
        shipping_carrier: "USPS",
        shipping_method: "PRIO",
      })
    end

    it { expect(order.to_txt).to eq(test_eord_file) }
  end

  describe "#submit!" do
    let(:order) { 
      RsrGroup::Order.new({
        merchant_number: "12345",
        identifier: "1000-400",
        sequence_number: 1,
        username: "login",
        password: "password"
      })
    }

    before do
      order.add_recipient({
        shipping_name: 'Bellatrix',
        address_one: '123 Winchester Ave',
        city: 'Happyville',
        state: 'CA',
        zip: '12345',
        phone: '(888) 999-000',
        email: 'email@example.com'
      }, {
        license_number: 'aa-bb-01-cc',
        name: 'Balrog',
        zip: '22122',
        end_customer_name: 'Gimlee',
        end_customer_phone: '555',
      })

      order.add_item({
        rsr_stock_number: "BRS34002",
        quantity: 1,
        shipping_carrier: "USPS",
        shipping_method: "PRIO",
      })

      ftp = instance_double("Net::FTP", :passive= => true, :debug_mode= => true)
      allow(ftp).to receive(:chdir).with("eo/incoming") { true }
      allow(ftp).to receive(:storlines).with("STOR " + order.filename, instance_of(StringIO)) { true }
      allow(ftp).to receive(:nlst) { [order.filename] }
      allow(ftp).to receive(:mtime).with(order.filename) { Time.now }
      allow(ftp).to receive(:size).with(order.filename) { 314 }
      allow(Net::FTP).to receive(:open).with("ftp.host.com", "2222", "login", "password") { |&block| block.call(ftp) }
      allow(ftp).to receive(:close)
    end

    it { expect(order.submit!.success?).to be(true) }
  end

end
