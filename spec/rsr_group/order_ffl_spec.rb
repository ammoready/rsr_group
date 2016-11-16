require 'spec_helper'

describe RsrGroup::OrderFFL do

  let(:order_ffl) {
    RsrGroup::OrderFFL.new({
      order_identifier: "AR1112",
      licence_number: "aa-bb-01-cc",
      name: "Balrog",
      zip: "22122"
    })
  }

  describe "#initialize" do 
    it { expect(order_ffl.order_identifier).to eq("AR1112") }
  end

  describe "#to_single_line" do
    it { expect(order_ffl.to_single_line).to eq("AR1112;11;aa-bb-01-cc;Balrog;22122") }
  end

end
