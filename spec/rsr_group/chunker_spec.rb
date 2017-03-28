require "spec_helper"

describe RsrGroup::Chunker do

  before do
    @chunker = RsrGroup::Chunker.new(10)
  end

  it "has accessors" do
    @chunker.should have_attr_accessor(:chunk)
    @chunker.should have_attr_accessor(:file_length)
    @chunker.should have_attr_accessor(:count)
    @chunker.should have_attr_accessor(:size)
  end

  it "tracks count when chunk is added" do
    5.times do
      @chunker.add(["data"])
    end

    @chunker.chunk.count.should eq(5)
  end

  it "should know when it's full" do
    10.times do
      @chunker.add(["data"])
    end

    @chunker.is_full?.should == true
  end

  it "should know when it's completed" do
    @chunker.file_length = 20

    20.times do
      @chunker.add(["data"])
    end

    @chunker.is_completed?.should == true
  end

end
