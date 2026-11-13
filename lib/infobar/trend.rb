# Determines a trend direction (up, flat, down) from a series of
# values using linear regression.
#
# @example Trend from a FIFO of rate samples
#   Infobar::Trend.new([1.0, 1.1, 1.2]).to_s
#     # => "↗"
class Infobar::Trend
  # Initializes a new Trend indicator.
  #
  # @param values [Array<Numeric>] the data series to analyze
  # @param symbols [Array<Symbol>] the three symbols for down,
  #   flat, and up (default +[↘, →, ↗]+)
  def initialize(values, symbols: %i[ ↘ → ↗ ])
    @values  = values
    @symbols = symbols
    @string  = arrow
  end

  # Returns the trend arrow as a string.
  #
  # @return [String] one of the configured symbols
  def to_s
    @string
  end

  private

  # Computes the arrow by fitting a linear regression on the values.
  #
  # @return [String] the matching symbol from +@symbols+
  def arrow
    lr = MoreMath::LinearRegression.new(@values)
    case
    when lr.slope_zero?
      @symbols[1]
    when lr.a > 0
      @symbols[2]
    else
      @symbols[0]
    end.to_s
  end
end
