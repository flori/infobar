# A formatted numeric string supporting unit-aware and plain formats.
#
# When the format contains +%U+, the value is rendered through
# +Tins::Unit#+format with the given unit and prefix. Otherwise a
# standard C-style format string is applied.
#
# @example Plain integer with thousands separator
#   Infobar::Number.new(1234567, format: '%d', separate: ?_).to_s
#     # => "1_234_567"
#
# @example Unit-aware rate
#   Infobar::Number.new(1500.0, format: '%.3f%U%t', unit: 'i/s').to_s
class Infobar::Number
  # Initializes a new Number formatter.
  #
  # @param value [Numeric] the value to format
  # @param format [String, nil] a C-style format string; if it
  #   contains +%U+ the value is unit-formatted via +Tins::Unit+
  # @param unit [String, nil] the unit label (default +'i/s'+ when
  #   using +%U+)
  # @param prefix [Integer] the unit prefix divisor (default 1000)
  # @param separate [String, nil] thousands separator inserted into
  #   integer values (e.g. +'?_'++)
  def initialize(value, format: nil, unit: nil, prefix: 1000, separate: nil)
    case format
    when /%U/
      unit   ||= 'i/s'
      prefix ||= 1000
      @string = Tins::Unit.format(value, format: format, unit: unit, prefix: prefix)
    else
      format ||= '%f'
      @string = format ? format % value : value.to_s
      if Integer === value && separate
        @string.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{separate}")
      end
    end
  end

  # Returns the pre-formatted number string.
  #
  # @return [String]
  def to_s
    @string
  end
end
