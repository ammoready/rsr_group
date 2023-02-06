require "spec_helper"

describe RsrGroup do
  it "has a version number" do
    expect(RsrGroup::VERSION).not_to be nil
  end

  describe "#configure" do
    before do
      RsrGroup.configure do |config|
        config.ftp_host       = "ftp.host.com"
        config.ftp_port       = "2222"
        config.submission_dir = File.join("eo", "incoming")
        config.vendor_email   = "admin@example.com"
      end
    end

    it { expect(RsrGroup.config.ftp_host).to eq("ftp.host.com") }
    it { expect(RsrGroup.config.ftp_port).to eq("2222") }
    it { expect(RsrGroup.config.submission_dir).to eq("eo/incoming") }
    it { expect(RsrGroup.config.vendor_email).to eq("admin@example.com") }
  end

end
