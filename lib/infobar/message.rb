require 'infobar/spinner'
require 'infobar/duration'
require 'infobar/number'
require 'infobar/rate'

# Renders a progress bar message from a format string containing
# registered `%`-directives.
#
# Directives like +%c+, +%t+, +%e+, +%s+ are resolved at render
# time by calling their registered blocks. Custom directives can
# be added via +Message.register+.
#
# @example Basic usage
#   msg = Infobar::Message.new(format: '%l %c/%t ETA %e %s')
#   msg.to_str # => "Infobar 12/100 ETA 00:45 |"
class Infobar::Message
  class << self
    prepend Tins::Delegate

    # Registers a new `%`-directive for use in message format strings.
    #
    # @param directive [String] the directive key, e.g. +'%c'+
    # @param opts [Hash] default options merged into each invocation
    # @yield [directive, opts] the block that produces the replacement
    #   string for this directive
    # @return [Infobar::Message] self for chaining
    #
    # @example Register a custom directive
    #   Message.register('%x', format: '%d') do |d, opts|
    #     Infobar::Number.new(some_value, **opts)
    #   end
    def register(directive, **opts, &block)
      directives.key?(directive) and
        warn "Overwriting old directive #{directive}."
      directives[directive]                = block
      directive_default_options[directive] = opts
      self
    end

    # @return [Hash] the registry of all registered directives
    def directives
      @directives ||= {}
    end

    # @return [Hash] default options keyed by directive
    def directive_default_options
      @directive_default_options ||= {}
    end
  end

  # current counter value of items
  register('%c', format: '%d', separate: ?_) do |directive, opts|
    Infobar::Number.new(infobar.counter.current, **opts)
  end

  # total counter value of items
  register('%t', format: '%d', separate: ?_) do |directive, opts|
    Infobar::Number.new(infobar.counter.total, **opts)
  end

  # number of items to go
  register('%T', format: '%d', separate: ?_) do |directive, opts|
    Infobar::Number.new(infobar.counter.to_go, **opts)
  end

  # label of progress bar
  register '%l' do
    infobar.label
  end

  # progressed so far as a float in 0..1
  register('%p', format: '%.3f') do |directive, opts|
    Infobar::Number.new(infobar.counter.progressed, **opts)
  end

  # not yet progressed as a float in 0..1
  register('%q', format: '%1.3f') do |directive, opts|
    Infobar::Number.new(1 - infobar.counter.progressed, **opts)
  end

  # progressed as a percentage float in 0..100
  register('%P', format: '%3.2f') do |directive, opts|
    Infobar::Number.new(100 * infobar.counter.progressed, **opts)
  end

  # not yet progressed as a percentage float in 0..100
  register('%Q', format: '%2.2f') do |directive, opts|
    Infobar::Number.new(100 - 100 * infobar.counter.progressed, **opts)
  end

  # time elapsed as a duration
  register('%te', format: '%D') do |directive, opts|
    Infobar::Duration.new(infobar.counter.time_elapsed, **opts)
  end

  # total time as a duration
  register('%tt', format: '%D') do |directive, opts|
    Infobar::Duration.new(infobar.counter.total_time, **opts)
  end

  # ETA as a duration
  register('%e', format: '%D') do |directive, opts|
    Infobar::Duration.new(infobar.counter.time_remaining, **opts)
  end

  # ETA as a datetime
  register('%E', format: '%T') do |directive, opts|
    if format = opts[:format]
      infobar.counter.eta.strftime(format)
    else
      infobar.counter.eta
    end
  end

  # rate with or without units
  register('%r', unit: 'i/s', prefix: 1000, format: '%.3f%U%t') do |directive, opts|
    Infobar::Rate.new(infobar.counter.rate, infobar.counter.fifo_rate, **opts)
  end

  # average time as a duration
  register('%a', format: '%m:%s.%f') do |directive, opts|
    Infobar::Duration.new(infobar.counter.average_time, **opts)
  end

  # spinner
  register('%s', frames: :pipe, message: ?✓) do |directive, opts|
    if infobar.finished?
      if message = opts[:message]
        infobar.convert_to_message(message).to_str
      end
    elsif opts[:random]
      Infobar::Spinner.new(opts[:frames]).spin(:random)
    else
      Infobar::Spinner.new(opts[:frames]).spin(infobar.display.updates)
    end
  end

  # literal percentage character
  register '%%' do
    ?%
  end

  # Initializes a new Message with the given options.
  #
  # @param opts [Hash] message options; must contain a +'format'+
  #   key with the format string. Additional keys are per-directive
  #   option overrides (stringified keys).
  #
  # @example
  #   Message.new(format: '%l %c/%t', '%c' => { format: '%03d' })
  def initialize(opts)
    @opts = opts.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
  end

  # @!attribute [r] opts
  #   @return [Hash] the raw options hash
  attr_reader :opts

  # @return [Hash] the class-level directive registry
  def directives
    self.class.directives
  end

  # @return [Hash] the class-level default options registry
  def directive_default_options
    self.class.directive_default_options
  end

  # Resolves options for a given directive, falling back to the
  # registered defaults.
  #
  # @param directive [String] the directive key
  # @return [Hash] the effective options for this directive
  def opts_for(directive)
    @opts.fetch(directive, directive_default_options[directive])
  end

  # Renders the format string, replacing all directives with their
  # resolved values.
  #
  # @return [String] the fully rendered message
  def to_str
    keys = directives.keys.sort_by { |k| -k.size }
    format.gsub(/(?<!%)(#{keys * ?|})/) do
      directives[$1].call($1, opts_for($1))
    end
  end

  # @return [String, nil] the raw format string
  def format
    @opts['format']
  end

  alias to_s format

  # Returns the options as a symbolized hash with +:format+ as the
  # format key.
  #
  # @return [Hash]
  def to_hash
    result = @opts.dup
    result[:format] = result.delete('format')
    result
  end
end
