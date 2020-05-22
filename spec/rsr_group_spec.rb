require "spec_helper"

describe RsrGroup do

  describe 'constants' do
    it { expect(RsrGroup::FILE_TYPES).to be_a(Hash) }
    it { expect(RsrGroup::LINE_TYPES).to be_a(Hash) }
    it { expect(RsrGroup::SHIPPING_CARRIERS).to be_a(Array) }
    it { expect(RsrGroup::SHIPPING_METHODS).to be_a(Hash) }
    it { expect(RsrGroup::ERROR_CODES).to be_a(Hash) }
  end

  describe "#configure" do
    before do
      RsrGroup.configure do |config|
        config.ftp_host       = "ftp.host.com"
        config.submission_dir = File.join("eo", "incoming")
        config.vendor_email   = "admin@example.com"
      end
    end

    it { expect(RsrGroup.config.ftp_host).to eq("ftp.host.com") }
    it { expect(RsrGroup.config.submission_dir).to eq("eo/incoming") }
    it { expect(RsrGroup.config.vendor_email).to eq("admin@example.com") }
  end

end
