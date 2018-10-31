require 'spec_helper'

describe RsrGroup::Base do

  describe ".connect" do
    it 'requires username and password options' do
      expect { RsrGroup::Base.connect(username: 'usr') }.to raise_error(ArgumentError)
      expect { RsrGroup::Base.connect(password: 'psw') }.to raise_error(ArgumentError)
    end
  end

end
