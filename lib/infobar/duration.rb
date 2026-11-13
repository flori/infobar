# A formatted duration string backed by +Tins::Duration.
#
# @example Create a default-formatted duration
#   Infobar::Duration.new(42.5).to_s
#
# @example Custom format
#   Infobar::Duration.new(42.5, format: '%m:%s').to_s
#     # => "00:42"
class Infobar::Duration
  # Initializes a new Duration.
  #
  # @param value [Numeric] the number of seconds
  # @param format [String, nil] a +Tins::Duration#+format string,
  #   e.g. +'%D'+, +'%m:%s'+, or +nil+ for the default
  def initialize(value, format: nil)
    duration = Tins::Duration.new(value)
    @string =
      if format
        duration.format(format)
      else
        duration
      end.to_s
  end

  # Returns the pre-formatted duration string.
  #
  # @return [String]
  def to_s
    @string
  end
end
