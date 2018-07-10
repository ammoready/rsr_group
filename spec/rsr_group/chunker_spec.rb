require "spec_helper"

describe RsrGroup::Chunker do

  before do
    @chunker = RsrGroup::Chunker.new(10)
  end

  it "has accessors" do
    expect(@chunker).to have_attr_accessor(:chunk)
    expect(@chunker).to have_attr_accessor(:total_count)
    expect(@chunker).to have_attr_accessor(:current_count)
    expect(@chunker).to have_attr_accessor(:size)
  end

  it "tracks count when chunk is added" do
    5.times do
      @chunker.add(["data"])
    end

    expect(@chunker.chunk.count).to eq(5)
  end

  it "should know when it's full" do
    10.times do
      @chunker.add(["data"])
    end

    expect(@chunker.is_full?).to eq(true)
  end

  it "should know when it's complete" do
    @chunker.total_count = 20

    20.times do
      @chunker.add(["data"])
    end

    expect(@chunker.is_complete?).to eq(true)
  end

end
