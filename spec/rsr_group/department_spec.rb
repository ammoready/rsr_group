require 'spec_helper'

describe RsrGroup::Department do

  it 'has a NAMES constant' do
    expect(RsrGroup::Department::NAMES).not_to be_nil
  end

  context "attrs" do    
    it { expect(RsrGroup::Department.new("01")).to respond_to(:id) }
  end

  describe "#name" do    
    it { expect(RsrGroup::Department.new("01").name).to eq("Handguns") }
  end

end
