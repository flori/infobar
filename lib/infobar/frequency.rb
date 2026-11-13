# Throttles execution to a fixed time interval.
#
# Tracks the timestamp of the last invocation and only allows a
# block to run when the configured +duration+ has elapsed since
# the previous call.
class Infobar::Frequency
  # Initializes a new Frequency gate.
  #
  # @param duration [Numeric] minimum seconds between calls
  def initialize(duration)
    @duration = duration.to_f
    @called   = 0
  end

  # The configured minimum interval in seconds.
  #
  # @return [Float]
  attr_reader :duration

  # The number of times the block has been permitted to run.
  #
  # @return [Integer]
  attr_reader :called

  # Records the current (or given) timestamp and increments the
  # call counter.
  #
  # @param now [Time] the reference time (defaults to +Time.now+)
  def update(now: Time.now)
    @update = now
    @called += 1
  end

  # Executes the block if the frequency threshold has been met.
  #
  # @yield The block to execute when the interval has elapsed
  def call(&block)
    now = Time.now
    if !@update || now - @update > @duration
      update now: now
      block.call
    end
  end

  # Resets the internal state so the next call is always permitted.
  #
  # @return [Infobar::Frequency] self
  def reset
    @update = nil
    @called = 0
    self
  end

  # Returns the configured duration as a string.
  #
  # @return [String]
  def to_s
    @duration.to_s
  end
end
