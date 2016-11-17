require 'spec_helper'

describe RsrGroup::Base do

  describe ".ftp_host" do
    it { expect(RsrGroup::Base.ftp_host).to eq('ftp.rsrgroup.com') }
  end

  describe "#connect" do
    pending
  end

end
