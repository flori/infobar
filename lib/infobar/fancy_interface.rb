# A syntactic sugar module that lets you treat an +Infobar+ instance
# like a counter with familiar operators.
#
# @example Basic usage
#   Infobar(total: 10)
#   +infobar
#   infobar << item
#   infobar.add(1, 2, 3)
module Infobar::FancyInterface
  # Resets the counter and display.
  # @return [Infobar] the infobar instance
  def ~
    reset
  end

  # Advances progress by 1 under the +true+ key.
  # @return [Infobar] the infobar instance
  def +@
    progress by: 1, as: true
  end

  # Advances progress by 1 under the +false+ key.
  # @return [Infobar] the infobar instance
  def -@
    progress by: 1, as: false
  end

  # Advances progress by +by+ under the +true+ key.
  # @param by [Integer] the number of items to advance
  # @return [Infobar] the infobar instance
  def +(by)
    progress by: by, as: true
  end

  # Advances progress by +by+ under the +false+ key.
  # @param by [Integer] the number of items to advance
  # @return [Infobar] the infobar instance
  def -(by)
    progress by: by, as: false
  end

  # Enables +infobar + other+ and +other + infobar+ syntax.
  # @param other [Object] the other operand
  # @return [Array] a two-element array for coercion
  def coerce(other)
    return self, other
  end

  # Advances progress by 1 (shorthand for +progress+).
  # @param item [Object] the item being processed (unused)
  # @return [Infobar] the infobar instance
  def <<(item)
    progress by: 1
  end

  # Advances progress by the number of items given.
  # @param items [Array] the items being processed
  # @return [Infobar] the infobar instance
  def add(*items)
    progress by: items.size
  end
  alias push add
end
