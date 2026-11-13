# A terminal spinner that cycles through a set of frame strings.
#
# Supports custom frame arrays or any of the built-in +PREDEFINED+
# animations (e.g. pipe, braille, cylon, pacman).
class Infobar::Spinner
  # Built-in frame sets keyed by symbol.
  #
  # @api private
  PREDEFINED = {
    pipe:       %w[ | / – \\ ],
    arrow:      %w[ ↑ ↗ → ↘ ↓ ↙ ← ↖ ],
    bar1:       %w[ ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▇ ▆ ▅ ▄ ▃ ▂ ],
    bar2:       %w[ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏ ▎ ▍ ▌ ▋ ▊ ▉ ],
    braille7:   %w[ ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ ],
    braille1:   %w[ ⠁ ⠂ ⠄ ⡀ ⢀ ⠠ ⠐ ⠈ ],
    braille18:  %w[ ⡀ ⡄ ⡆ ⡇ ⣇ ⣧ ⣷ ⣿ ],
    braille181: %w[ ⡀ ⡄ ⡆ ⡇ ⣇ ⣧ ⣷ ⣿  ⣷ ⣧ ⣇ ⡇ ⡆ ⡄ ⡀ ],
    square1:    %w[ ▖ ▘ ▝ ▗ ],
    square2:    %w[ ◰ ◳ ◲ ◱ ],
    tetris:     %w[ ▌ ▀ ▐▄ ],
    eyes:       %w[ ◡◡ ⊙⊙ ◠◠ ],
    corners:    %w[ ┤ ┘ ┴ └ ├ ┌ ┬ ┐ ],
    triangle:   %w[ ◢ ◣ ◤ ◥ ],
    circle1:    %w[ ◴ ◷ ◶ ◵ ],
    circle2:    %w[ ◐ ◓ ◑ ◒ ],
    circle3:    %w[ ◜ ◝ ◞ ◟ ],
    cross:      %w[ + × ],
    cylon:      [ '●  ', ' ● ', '  ●', ' ● ' ],
    pacman:     [ 'ᗧ∙∙∙∙●', ' O∙∙∙●', '  ᗧ∙∙●','   O∙●', '    ᗧ●', 'ᗣ    O', ' ᗣ   ᗤ', ' ᗣ  O ', ' ᗣ ᗤ  ', ' ᗣO   ', ' ᗤ    ', 'O ∞   ', 'ᗧ   ∞ ', 'O     ' ],
    asteroids:  [ 'ᐊ  ◍', 'ᐃ  ◍', 'ᐓ  ◍', 'ᐅ· ◍', 'ᐅ ·◍', 'ᐅ  ○', 'ᐅ  ◌', 'ᐁ   ' ],
    clock:      %w[ 🕐 🕜 🕑 🕝 🕒 🕞 🕓 🕟 🕔 🕠 🕕 🕡 🕖 🕢 🕗 🕣 🕘 🕤 🕙 🕥 🕚 🕦 🕛 🕧 ],
    hourglass:  %w[ ⏳ ⌛ ],
  }

  # Initializes a new Spinner.
  #
  # @param frames [Array<String>, Symbol, nil] a custom frame array,
  #   a +PREDEFINED+ key (e.g. +:pipe+), or +nil+ for the default
  #   pipe animation
  # @raise [KeyError] if a +Symbol+ is given that is not in
  #   +PREDEFINED+
  def initialize(frames = nil)
    @frames =
      case frames
      when Array
        frames
      when Symbol
        PREDEFINED.fetch(frames) do
          |k| raise KeyError, "frames #{k} not predefined"
        end
      when nil
        PREDEFINED[:pipe]
      end
  end

  # Advances the spinner to the frame at the given index.
  #
  # @param count [Integer, :random] the frame index (wrapped
  #   modulo the frame count) or +:random+ for a random frame
  # @return [Infobar::Spinner] self
  def spin(count)
    @string =
      if count == :random
        @frames[rand(@frames.size)]
      else
        @frames[count % @frames.size]
      end
    self
  end

  # Returns the current frame string.
  #
  # @return [String]
  def to_s
    @string
  end
end
