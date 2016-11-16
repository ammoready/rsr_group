require 'spec_helper'

describe RsrGroup::OrderRecipient do
  
  let(:order_recipient) { 
    RsrGroup::OrderRecipient.new({
      order_identifier: "AR1112",
      shipping_name: "Bellatrix",
      address_one: "123 Winchester Ave",
      city: "Happyville",
      state: "CA",
      zip: "12345",
      phone: "888999000",
      email: "email@example.com",
    })
  }

  context "attributes" do
    describe "#order_identifier" do
      it { expect(order_recipient.order_identifier).to eq("AR1112") }
    end

    describe "#ffl" do
      let(:ffl) { Object.new }

      before do
        order_recipient.ffl = ffl
      end

      it { expect(order_recipient.ffl).to eq(ffl) }
    end

    describe "#items" do
      context "defaults to empty array" do
        it { expect(order_recipient.items).to eq([]) }
      end

      context "allows assignment to array" do
        let(:object1) { Object.new }
        let(:object2) { Object.new }

        before do
          order_recipient.items << object1
          order_recipient.items << object2
        end

        it { expect(order_recipient.items).to match_array([object1, object2]) }
      end
    end
  end

  describe "#to_single_line" do
    it { expect(order_recipient.to_single_line).to eq("AR1112;10;Bellatrix;;123 Winchester Ave;;Happyville;CA;12345;888999000;Y;email@example.com;;") }
  end

  describe "#trailer" do
    before do
      allow(order_recipient).to receive(:items) { [OpenStruct.new(quantity: 2), OpenStruct.new(quantity: 1)] }
    end

    it { expect(order_recipient.trailer).to eq("AR1112;90;0000003") }
  end

end
