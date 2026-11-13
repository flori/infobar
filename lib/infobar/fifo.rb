# A fixed-capacity first-in-first-out buffer.
#
# Includes +Enumerable+ for iteration. When the buffer is full, the
# oldest element is evicted on push.
#
# @example Create and fill a FIFO
#   fifo = Infobar::FIFO.new(3)
#   fifo << 1  # => 1
#   fifo << 2  # => 2
#   fifo << 3  # => 3
#   fifo << 4  # => 4 (1 is evicted)
class Infobar::FIFO
  include Enumerable

  # Initializes a new FIFO with the given maximum capacity.
  #
  # @param n [Integer] the maximum number of elements to retain
  def initialize(n)
    @n = n
    clear
  end

  # Returns the maximum capacity of the buffer.
  #
  # @return [Integer]
  def max_size
    @n
  end

  # Pushes a value into the buffer, evicting the oldest element
  # if the buffer is at capacity.
  #
  # @param value [Object] the element to push
  # @return [Infobar::FIFO] self for chaining
  def <<(value)
    @i += 1
    if @i > @n
      @values.shift
      @i -= 1
    end
    @values.push(value)
    self
  end

  # Iterates over all elements currently in the buffer.
  #
  # @yield [element] yields each stored element
  # @return [Infobar::FIFO] self
  def each(&block)
    @values.each(&block)
    self
  end

  # Whether the buffer is empty.
  #
  # @return [Boolean]
  def empty?
    @i.zero?
  end

  alias size count

  # Clears all elements from the buffer.
  #
  # @return [Infobar::FIFO] self
  def clear
    @i = 0
    @values = []
    self
  end
end
