module RsrGroup
  class Chunker

    attr_accessor :chunk, :file_length, :count, :size

    def initialize(size, file_length = nil)
      @size         = size
      @chunk        = []
      @count        = 0
      @file_length  = file_length
    end

    def add(row)
      @chunk << row

      @count += 1
    end

    def is_full?
      if @chunk.count == @size
        @chunk = []

        true
      else
        false
      end
    end

    def is_completed?
      @file_length == @count
    end

  end
end
