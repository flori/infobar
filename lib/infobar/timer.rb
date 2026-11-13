require 'infobar/fifo'

# Tracks processing rate using a Welford-style online mean.
#
# Accepts time-and-count samples, maintains a running average of
# per-item duration, and pushes each new rate into a 30-slot
# +FIFO+ for trend detection.
class Infobar::Timer
  # Initializes a new Timer with zeroed statistics and an empty
  # 30-slot FIFO.
  def initialize
    @n    = 0
    @x    = 0.0
    @fifo = Infobar::FIFO.new(30)
  end

  # The running online mean of per-item time (seconds).
  #
  # @return [Float]
  attr_reader :x

  # The number of samples fed into the online mean.
  #
  # @return [Integer]
  attr_reader :n

  # The 30-slot +FIFO+ of recent rate samples.
  #
  # @return [Infobar::FIFO]
  attr_reader :fifo

  # Records a processing sample.
  #
  # On the first call it primes the timer; on the second call it
  # seeds the mean with two samples (including the gap between
  # calls); subsequent calls push a single rate sample.
  #
  # @param time [Time] the timestamp of this sample
  # @param count [Integer] the number of items processed since the
  #   last call
  # @return [Infobar::Timer] self
  def add(time, count)
    case @n
    when 0
      @n += 1
    when 1
      @n -= 1
      duration = time - @time_last
      self << (duration / @count_last)
      self << (duration / count.to_f)
    else
      duration = time - @time_last
      self << (duration / count.to_f)
    end
    @time_last, @count_last = time, count
    self
  end

  # The current items-per-second rate.
  #
  # @return [Float] 1.0 divided by the average per-item time, or
  #   0.0 if no samples exist
  def rate
    if @x.zero?
      0.0
    else
      1.0 / @x
    end
  end

  # The average time per item in seconds.
  #
  # @return [Float]
  def average_time
    @x
  end

  protected

  # Pushes a single per-item time sample into the online mean and
  # the rate FIFO.
  #
  # @api protected
  # @param x [Float] the per-item duration in seconds
  # @return [Infobar::Timer] self
  def <<(x)
    @n +=1
    @x += (x - @x) / @n
    @fifo << rate
    self
  end
end
