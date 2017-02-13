require 'spec_helper'

describe RsrGroup::DataRow do

  describe ".new" do
    context "order_header (10)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord001;10;Gimle;;2000 Shore Dr.;Bldg 1;Orlando;FL;32751;8889990000;Y;fulfillment@gunsrus.com;mdevaney@gunsrus.com;A ") }
      
      it { expect(data_row.identifier).to eq("grsord001") }
      it { expect(data_row.line_type).to eq(:order_header) }
      it { expect(data_row.ship_to_name).to eq("Gimle") }
      it { expect(data_row.zip).to eq("32751") }
    end

    context "ffl_dealer (11)" do
      let(:data_row) { RsrGroup::DataRow.new("AR1112;11;aa-bb-01-cc;Balrog;22122") }

      it { expect(data_row.identifier).to eq("AR1112") }
      it { expect(data_row.licence_number).to eq("aa-bb-01-cc") }
      it { expect(data_row.line_type).to eq(:ffl_dealer) }
      it { expect(data_row.name).to eq("Balrog") }
      it { expect(data_row.zip).to eq("22122") }
    end

    context "order_detail (20)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord001;20;AUT12KT;00002;UPS;Grnd") }

      it { expect(data_row.identifier).to eq("grsord001") }
      it { expect(data_row.line_type).to eq(:order_detail) }
      it { expect(data_row.quantity).to eq(2) }
      it { expect(data_row.stock_id).to eq("AUT12KT") }
      it { expect(data_row.shipping_carrier).to eq("UPS") }
      it { expect(data_row.shipping_method).to eq("Ground") }
    end

    context "confirmation_header (30)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord002;30;08776;") }

      it { expect(data_row.identifier).to eq("grsord002") }
      it { expect(data_row.line_type).to eq(:confirmation_header) }
      it { expect(data_row.rsr_order_number).to eq("08776") }
    end

    context "confirmation_detail (40)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord002;40;BRS34002;00001;00001;") }

      it { expect(data_row.committed).to eq(1) }
      it { expect(data_row.identifier).to eq("grsord002") }
      it { expect(data_row.line_type).to eq(:confirmation_detail) }
      it { expect(data_row.ordered).to eq(1) }
      it { expect(data_row.stock_id).to eq("BRS34002") }
    end

    context "confirmation_trailer (50)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord002;50;000000004;000000004;") }

      it { expect(data_row.committed).to eq(4) }
      it { expect(data_row.identifier).to eq("grsord002") }
      it { expect(data_row.line_type).to eq(:confirmation_trailer) }
      it { expect(data_row.ordered).to eq(4) }
    end

    context "shipping_header (60)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord003;60;Legolas;21113109383000476953;58778;20120801;0000001200;0000000000;USPS;PRIO;") }

      it { expect(data_row.identifier).to eq("grsord003") }
      it { expect(data_row.line_type).to eq(:shipping_header) }
      it { expect(data_row.date_shipped).to eq(Time.parse("20120801")) }
      it { expect(data_row.handling_fee).to eq("0") }
      it { expect(data_row.rsr_order_number).to eq("58778") }
      it { expect(data_row.ship_to_name).to eq("Legolas") }
      it { expect(data_row.shipping_cost).to eq("1200") }
      it { expect(data_row.shipping_carrier).to eq("USPS") }
      it { expect(data_row.shipping_method).to eq("PRIO") }
      it { expect(data_row.tracking_number).to eq("21113109383000476953") }
    end

    context "shipping_detail (70)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord003;70;BRS34002;00001;00001;") }

      it { expect(data_row.identifier).to eq("grsord003") }
      it { expect(data_row.line_type).to eq(:shipping_detail) }
      it { expect(data_row.ordered).to eq(1) }
      it { expect(data_row.shipped).to eq(1) }
      it { expect(data_row.stock_id).to eq("BRS34002") }
    end

    context "shipping_trailer (80)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord003;80;000000001;000000001;") }

      it { expect(data_row.identifier).to eq("grsord003") }
      it { expect(data_row.line_type).to eq(:shipping_trailer) }
      it { expect(data_row.ordered).to eq(1) }
      it { expect(data_row.shipped).to eq(1) }
    end

    context "order_trailer (90)" do
      let(:data_row) { RsrGroup::DataRow.new("grsord003;90;0000001") }

      before do
        pp data_row.to_h
      end

      it { expect(data_row.identifier).to eq("grsord003") }
      it { expect(data_row.line_type).to eq(:order_trailer) }
      it { expect(data_row.quantity).to eq(1) }
    end

  end

end
