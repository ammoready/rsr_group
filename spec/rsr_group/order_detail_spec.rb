require 'spec_helper'

describe RsrGroup::OrderDetail do

  describe "attributes" do
    let(:order_detail) { 
      RsrGroup::OrderDetail.new({
        order_identifier: "AR111",
        rsr_stock_number: "BRS34002",
        quantity: 1,
        shipping_carrier: "USPS",
        shipping_method: "PRIO",
      })
    }

    it { expect(order_detail.order_identifier).to eq("AR111") }
    it { expect(order_detail.instance_variable_get(:@rsr_stock_number)).to eq("BRS34002") }
    it { expect(order_detail.instance_variable_get(:@quantity)).to eq("00001") }
    it { expect(order_detail.instance_variable_get(:@shipping_carrier)).to eq("USPS") }
    it { expect(order_detail.instance_variable_get(:@shipping_method)).to eq("PRIO") }
  end

  describe "#to_single_line" do
    let(:order_detail) { 
      RsrGroup::OrderDetail.new({
        order_identifier: "AR111",
        rsr_stock_number: "BRS34002",
        quantity: 1,
        shipping_carrier: "USPS",
        shipping_method: "PRIO",
      })
    }

    it { expect(order_detail.to_single_line).to eq("AR111;20;BRS34002;00001;USPS;PRIO") }
  end

end
