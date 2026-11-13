require 'infobar/trend'

# Formats a processing rate with optional unit scaling and a trend
# arrow derived from recent FIFO samples.
class Infobar::Rate
  # Initializes a new Rate formatter.
  #
  # @param value [Numeric] the rate value to format
  # @param fifo_values [Array<Numeric>] recent rate samples used to
  #   compute the trend arrow
  # @param opts [Hash] formatting options
  # @option opts [String] :format the format string (default
  #   +'%.3f%U%t'+); +%U+ triggers unit formatting, +%t+ is
  #   replaced by the trend symbol
  def initialize(value, fifo_values = [], **opts)
    opts[:format] ||= '%.3f%U%t'
    opts[:format] = add_trend(opts[:format], fifo_values)
    @string = value.full? do
      if opts[:format].include?('%U')
        Tins::Unit.format(value, **opts)
      else
        opts[:format] % value
      end
    end.to_s
  end

  # Returns the formatted rate string.
  #
  # @return [String]
  def to_s
    @string
  end

  private

  # Replaces the +%t+ placeholder in the format string with a trend
  # arrow (↘, →, or ↗) computed from the FIFO values, or with ⤿ if
  # no values are available.
  #
  # @api private
  # @param format [String] the format string containing +%t+
  # @param fifo_values [Array<Numeric>] the rate samples
  # @return [String] the format string with the trend symbol
  def add_trend(format, fifo_values)
    if fifo_values.empty?
      format.gsub('%t', ?⤿)
    else
      trend = Infobar::Trend.new(fifo_values)
      format.gsub('%t', trend.to_s)
    end
  end
end
