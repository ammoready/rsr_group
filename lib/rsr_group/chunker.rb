module RsrGroup
  class Chunker

    attr_accessor :chunk, :file_length, :current_count, :size

    def initialize(size, file_length = nil)
      @size           = size
      @chunk          = Array.new
      @current_count  = 0
      @file_length    = file_length
    end

    def add(row)
      reset if is_full?

      @chunk.push(row)

      @current_count += 1
    end

    def reset
      @chunk.clear
    end

    def is_full?
      @chunk.count == @size
    end

    def is_completed?
      @file_length == @current_count
    end

  end
end
