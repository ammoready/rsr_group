require 'spec_helper'

describe RsrGroup::Catalog do

  let(:sample_dir) { File.expand_path(File.join(Dir.pwd, 'spec', 'samples')) }
  let(:ftp) { instance_double('Net::FTP', :passive= => true, :debug_mode= => true) }
  let(:credentials) { { username: 'login', password: 'password' } }

  before do
    allow(Net::FTP).to receive(:open).with("ftp.host.com", {:password=>"password", :port=>"2222", :ssl=>true, :username=>"login"}) { |&block| block.call(ftp) }
  end

  describe '.all' do
    let(:sample_file) { File.new(File.join(sample_dir, 'rsrinventory-new.txt')) }

    before do
      allow(ftp).to receive(:nlst) { ['ftpdownloads'] }
      allow(ftp).to receive(:chdir).with('ftpdownloads') { true }
      allow(ftp).to receive(:getbinaryfile) { nil }
      allow(ftp).to receive(:close) { nil }
      allow(Tempfile).to receive(:new).and_return(sample_file)
      allow(sample_file).to receive(:unlink) { nil }
    end

    it 'returns an array of all items' do
      items = RsrGroup::Catalog.all(credentials)

      items.each_with_index do |item, index|
        case index
        when 0
          expect(item[:item_identifier]).to eq('RU-22C101')
          expect(item[:quantity]).to eq(0)
          expect(item[:price]).to eq('272.05')
        when 22
          expect(item[:item_identifier]).to eq('SU-22C108')
          expect(item[:quantity]).to eq(15)
          expect(item[:price]).to eq('290.25')
        when 41
          # This row is marked 'Allocated'
          expect(item[:item_identifier]).to eq('MU-22C112')
          expect(item[:quantity]).to eq(0)
          expect(item[:price]).to eq('133.30')
        end
      end

      expect(items.count).to eq(60)
    end
  end

end
