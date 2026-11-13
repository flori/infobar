require 'tins/xt'
require 'complex_config'
require 'more_math'

# Singleton progress bar manager.
#
# +Infobar+ is the primary entry point for creating and controlling
# terminal progress bars. It encapsulates a +Counter+ (state), a
# +Display+ (rendering), and a +Message+ (formatting) and exposes a
# compact API for updating progress.
#
# @example Basic usage
#   Infobar(total: 100)
#   100.times { +infobar }
#
# @example With a custom message
#   Infobar(total: 50, message: '%l %c/%t %s')
#
# @example Busy indicator (no total)
#   Infobar.busy(label: 'Thinking', frames: :braille1) {
#     do_long_work
#   }
class Infobar
end

require 'infobar/version'
require 'infobar/counter'
require 'infobar/display'
require 'infobar/message'
require 'infobar/fancy_interface'
require 'infobar/input_output'

class Infobar
  class << self
    prepend Tins::Delegate
  end
  include Singleton
  include Infobar::FancyInterface
  prepend Infobar::InputOutput
  include ComplexConfig::Provider::Shortcuts

  # Initializes the singleton with a fresh counter and display.
  def initialize
    @counter = Infobar::Counter.new
    @display = Infobar::Display.new
    reset display: false
  end

  # @return [Infobar::Display] the singleton display instance
  def self.display
    infobar.display
  end

  # @!attribute [r] message
  #   @return [Infobar::Message] the active message format
  attr_reader :message

  # @!attribute [r] counter
  #   @return [Infobar::Counter] the progress state tracker
  attr_reader :counter

  # @!attribute [r] display
  #   @return [Infobar::Display] the rendering output handler
  attr_reader :display

  # @!attribute [rw] label
  #   @return [String] the label shown in the progress bar
  attr_accessor :label

  # Whether the counter has started tracking time.
  #
  # @return [Boolean]
  delegate :started?, to: :counter

  # Whether the current count has reached the total.
  #
  # @return [Boolean]
  delegate :done?, to: :counter

  # Whether the bar has been explicitly finished.
  #
  # @return [Boolean]
  delegate :finished?, to: :counter

  # Whether the display is currently visible.
  #
  # @return [Boolean]
  delegate :show?, to: :display

  # Sets whether the display is visible.
  delegate :show=, to: :display

  # Merges new style options into the display style.
  delegate :style=, to: :display

  # Sets per-`as:` style overrides for the display.
  delegate :as_styles=, to: :display

  # Sets the input IO for the display.
  delegate :input=, to: :display

  # Sets the output IO for the display.
  delegate :output=, to: :display

  # Configures and activates the progress bar.
  #
  # @param opts [Hash] keyword arguments, see #call for the full list
  # @return [Infobar] self
  # @see #call
  def self.call(**opts)
    instance.call(**opts)
  end

  # Configures and activates the progress bar (instance form).
  #
  # @param total [Integer, Float] the total number of items
  # @param current [Integer] the starting progress value
  # @param label [String] the bar label
  # @param message [Hash, Infobar::Message, nil] the message format
  # @param show [Boolean, nil] whether the bar is visible
  # @param style [Hash, nil] display style overrides
  # @param as_styles [Hash, nil] per-`as:` style overrides
  # @param frequency [Numeric, nil] update frequency in seconds
  # @param update [Boolean] force an immediate update
  # @param input [IO] the input IO
  # @param output [IO] the output IO
  # @return [Infobar] self
  def call(
    total:,
    current:   0,
    label:     cc.infobar?&.label || 'Infobar',
    message:   cc.infobar?&.message?&.to_h,
    show:      cc.infobar?&.show?,
    style:     cc.infobar?&.style?&.to_h&.symbolize_keys_recursive,
    as_styles: cc.infobar?&.as_styles?&.to_h&.symbolize_keys_recursive,
    frequency: cc.infobar?&.frequency?,
    update:    false,
    input:     $stdin,
    output:    $stdout
  )
    self.label = label
    counter.reset(total: total, current: current)
    display.reset clear: false
    @message = convert_to_message(
      message.full? || '%l %c/%t in %te, ETA %e @%E %s'
    )
    show.nil? or self.show = show
    frequency.nil? or display.frequency = frequency
    style.nil? or self.style = style
    self.as_styles = as_styles
    self.input     = input
    self.output    = output
    update and update(message: @message, force: true)
    self
  end

  # Runs a busy indicator (spinner without a total) around a block.
  #
  # @param opts [Hash] keyword arguments, see #busy for the full list
  # @yield the work to perform
  # @return [Object] the result of the block
  # @see #busy
  def self.busy(**opts, &block)
    instance.busy(**opts, &block)
  end

  # Runs a busy indicator (spinner without a total) around a block.
  #
  # The block executes in a separate thread; the spinner updates
  # independently until the block completes.
  #
  # @param frames [Symbol] the spinner animation (see +Infobar::Spinner+)
  # @param opts [Hash] additional options forwarded to #call
  # @option opts [Numeric] :sleep the sleep interval in seconds (default 0.1)
  # @yield the work to perform
  # @yieldreturn [Object] the return value of the block
  # @return [Object] the result of the block
  #
  # @example
  #   Infobar.busy(label: 'Loading', frames: :braille1) {
  #     do_work
  #   }
  def busy(frames: :circle1, **opts, &block)
    block_given? or raise ArgumentError, 'block is required as an argument'
    duration = opts.delete(:sleep) || 0.1
    reset
    call(**opts | {
      total: Float::INFINITY,
      message: { format: ' %l %te %s ', '%s' => { frames: frames } },
    })
    ib = Thread.new {
      loop do
        +infobar
        sleep duration
      end
    }
    r = nil
    t = Thread.new { r = yield }
    t.join
    r
  ensure
    ib&.kill
    finish
    newline
  end

  # Resets the counter, message, and optionally the display.
  #
  # @param display [Boolean] whether to also clear the display
  #   (default true)
  # @return [Infobar] self
  def reset(display: true)
    @message = convert_to_message('%l %c/%t in %te, ETA %e @%E %s')
    counter.reset(total: 0, current: 0)
    display and self.display.reset
    self
  end

  # Renders an immediate update of the progress bar.
  #
  # @param message [String, Hash, Infobar::Message, nil] an optional
  #   new message format to render
  # @param force [Boolean] bypass the frequency limiter (default true)
  # @return [Infobar] self
  def update(message: nil, force: true)
    @message = convert_to_message(message)
    display.update(message: @message, counter: counter, force: force)
    self
  end

  # Advances the progress counter and renders an update.
  #
  # @param by [Integer] the number of items to add (default 1)
  # @param as [Symbol, String, nil] a named sub-progress category
  # @param message [String, Hash, Infobar::Message, nil] an optional
  #   new message format
  # @param finish [Boolean, String, Hash, nil] if truthy and the
  #   counter is done, calls #finish (default true)
  # @param force [Boolean] bypass the frequency limiter (default false)
  # @return [Infobar] self
  def progress(by: 1, as: nil, message: nil, finish: true, force: false)
    counter.progress(by: by, as: as)
    @message = convert_to_message(message)
    display.update(message: @message, force: force, counter: counter)
    finish && counter.done? and finish(message: finish)
    self
  end

  # Marks the progress bar as finished and renders a final update.
  #
  # @param message [String, Hash, Infobar::Message, nil] an optional
  #   final message to display
  # @return [Infobar] self
  def finish(message: nil)
    counter.finish
    @message = convert_to_message(message)
    display.update(message: @message, force: true, counter: counter)
    self
  end

  # Converts a message-like object to an +Infobar::Message+ (class form).
  #
  # @param message [String, Hash, Infobar::Message, Object]
  # @return [Infobar::Message]
  def self.convert_to_message(message)
    instance.convert_to_message(message)
  end

  # Converts a message-like object to an +Infobar::Message+.
  #
  # Accepts a +String+ (wraps in a format hash), a +Hash+ (passes to
  # +Message.new+), an existing +Message+ (returns as-is), or anything
  # else (returns the current @message).
  #
  # @param message [String, Hash, Infobar::Message, Object]
  # @return [Infobar::Message]
  def convert_to_message(message)
    case message
    when Message
      message
    when Hash
      Message.new(message)
    when String
      Message.new({format: message})
    else
      @message
    end
  end
end

# Creates and configures a new infobar (top-level convenience method).
#
# @param opts [Hash] keyword arguments forwarded to +Infobar.call+
# @return [Infobar] the configured singleton
#
# @example
#   Infobar(total: 42)
def Infobar(**opts)
  Infobar.(**opts)
end

class ::Object
  # Returns the +Infobar+ singleton instance.
  #
  # @return [Infobar]
  def infobar
    ::Infobar.instance
  end

  # Iterates over the receiver with a progress bar.
  #
  # If +:total+ is given as a symbol, it is resolved via
  # +__send__+. If +:total+ is not given, the receiver's +size+ is
  # used.
  #
  # @param opts [Hash] options forwarded to +Infobar.call+
  # @option opts [Integer, Symbol, nil] :total the total count or
  #   a method name to resolve it
  # @yield each element of the receiver
  # @return [Object] self
  #
  # @example
  #   (1..100).with_infobar.each { |i| process(i) }
  #
  # @example With a symbol total
  #   items.with_infobar(total: :count) { |item| save(item) }
  def with_infobar(**opts, &block)
    case
    when total = opts[:total].ask_and_send(:to_sym)
      opts[:total] = __send__(total)
    when opts[:total].nil?
      opts[:total] = size
    end
    Infobar.(**opts)
    block and each(&block)
    self
  end
end
