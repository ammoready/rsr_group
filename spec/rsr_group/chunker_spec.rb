require "spec_helper"

describe RsrGroup::Chunker do

  before do
    @chunker = RsrGroup::Chunker.new(10)
  end

  it "has accessors" do
    @chunker.should have_attr_accessor(:chunk)
    @chunker.should have_attr_accessor(:total_count)
    @chunker.should have_attr_accessor(:current_count)
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

  it "should know when it's complete" do
    @chunker.total_count = 20

    20.times do
      @chunker.add(["data"])
    end

    @chunker.is_complete?.should == true
  end

end
