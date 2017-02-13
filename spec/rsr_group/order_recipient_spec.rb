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

  describe "#to_single_line" do
    it { expect(order_recipient.to_single_line).to eq("AR1112;10;Bellatrix;;123 Winchester Ave;;Happyville;CA;12345;888999000;Y;email@example.com;;") }
  end

end
