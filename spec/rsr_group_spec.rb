require "spec_helper"

describe RsrGroup do
  it "has a version number" do
    expect(RsrGroup::VERSION).not_to be nil
  end

  describe "#configure" do
    before do
      RsrGroup.configure do |config|
        config.vendor_email = "admin@example.com"
      end
    end

    it { expect(RsrGroup.config.vendor_email).to eq("admin@example.com") }
  end

end
