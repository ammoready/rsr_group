require 'spec_helper'

describe RsrGroup::User do

  describe "#name" do
    let(:user) { RsrGroup::User.new(username: "bob", password: "kitty") }

    before do
      allow(Net::FTP).to receive(:open).and_return(Net::FTP.new)
    end

    it { expect(user.authenticated?).to be(true) }
  end

end
