require 'term/ansicolor'
require 'stringio'
require 'infobar/frequency'

# Terminal renderer for the progress bar.
#
# Draws a single-line bar with ANSI colors, respecting a
# configurable update +Frequency+. Supports per-category styling
# via +as_styles+ and a global +style+ hash.
#
# @example Create a display and update it
#   display = Infobar::Display.new
#   display.update(message: 'Working...', counter: counter)
class Infobar::Display
  class << self
    prepend Tins::Delegate
  end
  include Term::ANSIColor

  # Returns the default style hash for the progress bar.
  #
  # @return [Hash{Symbol => Object}] fill characters and ANSI colors
  def self.default_style
    {
      done_fill:     ?░,
      done_fg_color: 22,
      done_bg_color: 40,
      todo_fill:     ' ',
      todo_fg_color: 40,
      todo_bg_color: 22,
    }
  end

  # Creates a Display writing to +$stdout+ / reading from +$stdin+.
  def initialize
    self.output    = $stdout
    self.input     = $stdin
    self.frequency = 0.05
    @show          = true
    @style         = self.class.default_style.dup
  end

  # Sets the update frequency threshold.
  #
  # @param duration [Numeric] minimum seconds between updates
  def frequency=(duration)
    @frequency = Infobar::Frequency.new(duration)
  end

  # @!attribute [r] frequency
  #   @return [Infobar::Frequency] the rate-limiting gate
  attr_reader :frequency

  # @!attribute [rw] show
  #   @return [Boolean] whether output is rendered or discarded
  attr_accessor :show

  # Whether the display is currently visible.
  #
  # @return [Boolean]
  def show?
    @show
  end

  # Sets the output IO, enabling +sync+= if supported.
  #
  # @param io [IO] the destination for bar output
  def output=(io)
    @output = io
    @output.ask_and_send(:respond_to?, :sync=, true)
  end

  # Returns the active output IO, or +NULL+ when hidden.
  #
  # @return [IO]
  def output
    if show?
      @output
    else
      NULL
    end
  end

  # @!attribute [w] input
  #   Sets the source IO for user input.
  attr_writer :input

  # Returns the active input IO, or +NULL+ when hidden.
  #
  # @return [IO]
  def input
    if show?
      @input
    else
      NULL
    end
  end

  # @!attribute [r] style
  #   @return [Hash{Symbol => Object}] the current global style
  attr_reader :style

  # Merges new style options into the current style.
  #
  # @param new_style [Hash{Symbol => Object}] overrides to apply
  def style=(new_style)
    @style.update(**new_style)
  end

  # Per-category style overrides. Lazily initialized.
  #
  # @return [Hash{Symbol => Hash}] category-specific styles
  def as_styles
    defined? @as_styles or self.as_styles = {}
    @as_styles
  end

  # Sets per-category styles with a default proc falling back
  # to the global +done_*+ entries.
  #
  # @param styles [Hash] category name to style hash mapping
  def as_styles=(styles)
    @as_styles = styles.to_h.symbolize_keys_recursive
    @as_styles.default_proc = proc { style.subhash(/\Adone_/) }
  end

  # Renders the progress bar if the frequency gate allows.
  #
  # @param message [Infobar::Message, String, Hash, nil] the text
  #   to display alongside the bar
  # @param counter [Infobar::Counter, nil] the counter driving the bar
  # @param force [Boolean] bypass the frequency gate
  # @param options [Hash] additional style overrides for this update
  def update(message: nil, counter: nil, force: false, **options)
    force and @frequency.reset
    @frequency.call do
      carriage_return
      self.style = options
      message = infobar.convert_to_message(message)
      layout_bar(message, counter)
    end
  end

  private\
  def layout_bar(message, counter)
    cols = columns
    todo = message.to_str.center cols, replace_character

    if counter.total > 0
      max_done_length = counter.progressed * cols

      total_done = 0
      counter.as.each_with_index do |(name, count), i|
        style_name = name.to_s.to_sym
        done_fill     = as_styles[style_name].fetch(:done_fill) { @style[:done_fill] }
        done_fg_color = as_styles[style_name].fetch(:done_fg_color) { @style[:done_fg_color] }
        done_bg_color = as_styles[style_name].fetch(:done_bg_color) { @style[:done_bg_color] }

        as_progressed = count / counter.total.to_f
        as_done = as_progressed * cols
        total_done += as_done
        if counter.done? && i == counter.as.size - 1 && total_done <= max_done_length
          done = todo.dup
          todo = ''
        else
          done = todo.slice!(0, as_done)
        end
        done.gsub!(replace_character, done_fill[0])
        output << color(done_fg_color, on_color(done_bg_color, done))
      end
    end

    if todo.present?
      todo.gsub!(replace_character, @style[:todo_fill][0])
      output << color(@style[:todo_fg_color], on_color(@style[:todo_bg_color], todo))
    end
  end

  delegate :called, to: :frequency, as: :updates

  # Resets the display to defaults, optionally clearing the line.
  #
  # @param clear [Boolean] whether to blank the current line
  # @return [Infobar::Display] self
  def reset(clear: true)
    clear && self.clear
    self.style = self.class.default_style
    self
  end

  # Clears the current bar line and resets the frequency gate.
  #
  # @return [Infobar::Display] self
  def clear
    carriage_return
    output << ' ' * columns
    carriage_return
    @frequency.reset
    self
  end

  # Emits a carriage return to the output.
  #
  # @return [Infobar::Display] self
  def carriage_return
    output << ?\r
    self
  end

  # Emits a newline to the output.
  #
  # @return [Infobar::Display] self
  def newline
    output << $/
    self
  end

  private

  # The Unicode Object Replacement Character used as a
  # temporary fill during bar layout.
  #
  # @return [String]
  def replace_character
    "\uFFFC"
  end

  # Returns the current terminal width in columns.
  #
  # @return [Integer]
  def columns
    Tins::Terminal.columns
  end
end
