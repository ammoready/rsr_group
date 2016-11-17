require 'spec_helper'

describe RsrGroup::Base do

  describe ".ftp_host" do
    it { expect(RsrGroup::Base.ftp_host).to eq('ftp.host.com') }
  end

end
