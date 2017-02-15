require 'spec_helper'

describe RsrGroup::Department do

  it 'has a NAMES constant' do
    expect(RsrGroup::Department::NAMES).not_to be_nil
  end

  context 'attrs' do    
    it { expect(RsrGroup::Department.new("01")).to respond_to(:id) }
  end

  describe '#ammunition?' do
    it { expect(RsrGroup::Department.new("01").ammunition?).to eq(false) }
    it { expect(RsrGroup::Department.new("18").ammunition?).to eq(true) }
  end

  describe '#firearm?' do
    it { expect(RsrGroup::Department.new("01").firearm?).to eq(true) }
    it { expect(RsrGroup::Department.new("05").firearm?).to eq(true) }
    it { expect(RsrGroup::Department.new("18").firearm?).to eq(false) }
  end

  describe '#name' do    
    it { expect(RsrGroup::Department.new("01").name).to eq("Handguns") }
  end

end
