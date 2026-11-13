require 'infobar/timer'

# A progress counter that tracks items, rates, and elapsed time.
#
# Internally uses an +Infobar::Timer+ for Welford-style online
# mean computation and a +FIFO+ for rate trending.
#
# @example Create and advance a counter
#   counter = Infobar::Counter.new
#   counter.reset(total: 10)
#   counter.progress(by: 1)
class Infobar::Counter
  class << self
    prepend Tins::Delegate
  end

  # Creates a new Counter in a clean, zeroed state.
  def initialize
    reset
  end

  # @!attribute [r] current
  #   @return [Integer] the number of items processed so far
  attr_reader :current

  # @!attribute [r] total
  #   @return [Integer] the total number of items expected
  attr_reader :total

  # @!attribute [r] as
  #   @return [Hash{Object => Integer}] per-category counts keyed
  #     by the +as:+ label (+nil+ is the default bucket)
  attr_reader :as

  # Resets all internal state.
  #
  # @param total [Integer] total number of items
  # @param current [Integer] starting item count
  # @return [Infobar::Counter] self
  def reset(total: 0, current: 0)
    @current  = current
    @as       = Hash.new(0).update(nil => current)
    @total    = total
    @start    = nil
    @finished = false
    @timer    = Infobar::Timer.new
    self
  end

  delegate :rate, to: :@timer

  delegate :fifo, to: :@timer, as: :fifo_rate

  delegate :average_time, to: :@timer

  # Whether the counter has been started.
  #
  # @return [Time, nil] the start time, or +nil+ if not started
  def started?
    @start
  end

  # Whether the counter has been explicitly finished.
  #
  # @return [Time, false] the finish time, or +false+
  def finished?
    @finished
  end

  # Marks the counter as finished at the current time.
  #
  # @return [Infobar::Counter] self
  def finish
    @finished = Time.now
    self
  end

  # Advances the counter by the given amount.
  #
  # No-ops if the counter is finished or +by+ is less than 1.
  #
  # @param by [Integer] number of items to advance
  # @param as [Object, nil] category label for per-category tracking
  # @return [Infobar::Counter] self
  def progress(by: 1, as: nil)
    if !finished? && by >= 1
      now = Time.now
      @start ||= now
      @timer.add(now, by)
      @current += by
      @as[as] += by
    end
    self
  end

  # Whether all items have been processed.
  #
  # @return [Boolean]
  def done?
    @current >= @total
  end

  # Number of items remaining.
  #
  # @return [Integer] always >= 0
  def to_go
    [ total - current, 0 ].max
  end

  # Whether there are items remaining.
  #
  # @return [Integer, nil] the remaining count or +nil+ if zero
  def to_go?
    to_go.nonzero?
  end

  # Estimated seconds until completion.
  #
  # @return [Float] 0.0 if finished
  def time_remaining
    if @finished
      0.0
    else
      average_time * to_go
    end
  end

  # Estimated time of completion.
  #
  # @return [Time] the finish time or projected finish
  def eta
    if @finished
      @finished
    else
      Time.now + time_remaining
    end
  end

  # Seconds elapsed since the counter started.
  #
  # @return [Float] 0.0 if not started
  def time_elapsed
    case
    when @finished && @start
      @finished - @start
    when @start
      Time.now - @start
    else
      0.0
    end
  end

  # Total projected duration (elapsed + remaining).
  #
  # @return [Float]
  def total_time
    time_elapsed + time_remaining
  end

  # Progress as a float between 0 and 1.
  #
  # @return [Float] 0.0 when total is zero
  def progressed
    if @total.zero?
      0.0
    else
      @current / @total.to_f
    end
  end

  # Multi-line summary of per-category counts.
  #
  # @return [String] one line per category, e.g. +"default: 42"+
  def to_s
    n = -> k { k.nil? ? 'default' : k.to_s }
    width = -@as.keys.map(&n).max_by(&:size).to_i
    @as.map { |key, value| "%#{width}s: %d" % [ n.(key), value ] }.join(?\n)
  end
end
