# Prepended into +Infobar+ to intercept standard I/O methods so the
# progress bar is cleared before each write and the display IO is
# used as the target.
#
# Defines +print+, +printf+, +putc+, +puts+, +gets+, +readline+,
# +readlines+, +newline+, and +clear+ that all clear the bar first.
module Infobar::InputOutput
  # Clears the bar and writes a newline to the display output.
  # @return [Infobar] the infobar instance
  def newline
    display.newline
    self
  end

  # Clears the entire progress bar line.
  # @return [Infobar] the infobar instance
  def clear
    display.clear
    self
  end

  %i[ print printf putc puts ].each do |method|
    define_method(method) do |*a, &b|
      display.clear
      if display.output.respond_to?(method)
        display.output.public_send(method, *a, &b)
      end
    end
  end

  %i[ gets readline readlines ].each do |method|
    define_method(method) do |*a, &b|
      display.clear
      if display.input.respond_to?(method)
        display.input.public_send(method, *a, &b)
      end
    end
  end
end
