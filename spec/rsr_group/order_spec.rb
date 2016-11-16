require 'spec_helper'

describe RsrGroup::Order do

  before do
    now_double = double()
    allow(now_double).to receive(:strftime).with("%Y%m%e") { "20161212" }
    allow(Time).to receive(:now).and_return(now_double)
  end

  it 'has a LINE_TYPES constant' do
    expect(RsrGroup::Order::LINE_TYPES).not_to be_nil
  end

  let(:basic_order) { 
    RsrGroup::Order.new({
      identifier: "AR1112",
      sequence_number: 1,
      username: "12345",
      password: "kittycat"
    })
  }

  describe "#initialize" do 
    it { expect(basic_order.nil?).to be(false) }
    it { expect(basic_order.timestamp).to eq(Time.now.strftime("%Y%m%e")) }
    it { expect(basic_order.sequence_number).to eq("0001") }
  end

  describe "#header" do
    it { expect(basic_order.header).to eq("FILEHEADER;00;12345;20161212;0001") }
  end

  describe "#footer" do
    before do
      allow(basic_order).to receive(:recipients) { [OpenStruct.new(items: [Object.new])] }
    end

    it { expect(basic_order.footer).to eq("FILETRAILER;99;00001") }
  end

  describe "#filename" do
    it { expect(basic_order.filename).to eq("EORD-12345-20161212-0001.txt") }
  end

  describe "#to_txt" do
    let(:order) { 
      RsrGroup::Order.new({
        identifier: "AR1112",
        sequence_number: 1,
        username: "12345",
        password: "kittycat",
        recipients: [
          RsrGroup::OrderRecipient.new({
            order_identifier: "AR1112",
            shipping_name: "Bellatrix",
            address_one: "123 Winchester Ave",
            city: "Happyville",
            state: "CA",
            zip: "12345",
            phone: "888999000",
            email: "email@example.com",
            ffl: RsrGroup::OrderFFL.new({
              order_identifier: "AR1112",
              licence_number: "aa-bb-01-cc",
              name: "Balrog",
              zip: "22122",
            }),
            items: [
              RsrGroup::OrderDetail.new({
                order_identifier: "AR1112",
                rsr_stock_number: "BRS34002",
                quantity: 1,
                shipping_carrier: "USPS",
                shipping_method: "PRIO",
              }),
              RsrGroup::OrderDetail.new({
                order_identifier: "AR1112",
                rsr_stock_number: "AUT12KT",
                quantity: 1,
                shipping_carrier: "USPS",
                shipping_method: "PRIO",
              })
            ]
          })
        ]
      })
    }

    it { expect(order.to_txt).to eq(test_eord_file) }
  end

end
