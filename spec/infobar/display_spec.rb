require 'spec_helper'

describe Infobar::Display do
  let :output do
    StringIO.new
  end

  let :display do
    described_class.new
  end

  let :counter do
    Infobar::Counter.new.reset(total: 2, current: 1)
  end

  before do
    display.output = output
    allow(display).to receive(:columns).and_return 40
  end

  it 'can be updated' do
    display.update message: 'test', counter: counter
    expect(output.tap(&:rewind).read).to eq\
       "\r\e[38;5;22m\e[48;5;40m░░░░░░░░░░░░░░░░░░te\e[0m\e[0m\e[38;5;40m\e[48;5;22mst                  \e[0m\e[0m"
  end

  it 'update returns carriage first' do
    expect(display).to receive(:carriage_return).and_call_original
    display.update message: 'test', counter: counter
    expect(output.tap(&:rewind).read).to start_with ?\r
  end

  it 'reset clears and sets to default style' do
    expect(display).to receive(:clear).and_call_original
    expect(display).to receive(:style=).with(display.class.default_style)
    display.reset
  end

  it 'clear resets the frequency' do
    expect(display.frequency).to receive(:reset).and_call_original
    display.clear
  end

  it 'has style' do
    test_style = {
      done_fill:     ?X,
      done_fg_color: 1,
      done_bg_color: 9,
      todo_fill:     ?O,
      todo_fg_color: 0,
      todo_bg_color: 8
    }
    display.style = test_style
    display.update message: 'test', counter: counter
    expect(output.tap(&:rewind).read).to eq\
      "\r\e[38;5;1m\e[48;5;9mXXXXXXXXXXXXXXXXXXte\e[0m\e[0m\e[38;5;0m\e[48;5;8mstOOOOOOOOOOOOOOOOOO\e[0m\e[0m"
    expect(display.style).to eq(test_style)
  end

  it 'styles are different as kinds differ' do
    counter = Infobar::Counter.new.reset(total: 7, current: 5)
    expect(counter).to receive(:as).and_return(
      foo: 3,
      bar: 2
    )
    expect(display).to receive(:as_styles).and_return(
      {
        foo: {
          done_fill:     ?X,
          done_fg_color: 1,
          done_bg_color: 9,
        },
        bar: {
          done_fill:     ?*,
          done_fg_color: 0,
          done_bg_color: 10,
        }
      }
    ).at_least(:once)
    display.update message: 'test', counter: counter
    expect(output.tap(&:rewind).read).to eq\
      "\r\e[38;5;1m\e[48;5;9mXXXXXXXXXXXXXXXXX\e[0m\e[0m\e[38;5;0m\e[48;5;10m*test******\e[0m\e[0m\e[38;5;40m\e[48;5;22m            \e[0m\e[0m"
  end

  it 'can output newline' do
    expect(display.output).to receive(:<<).with($/)
    display.newline
  end

  it 'can be shown' do
    display.show = true
    expect(display).to be_show
    expect(output).to receive(:<<)
    display.output << 'hello world'
    expect(display.input).not_to be_nil
  end

  it 'can be hidden' do
    display.show = false
    expect(display).not_to be_show
    expect(output).not_to receive(:<<)
    display.output << 'hello world'
    expect(display.input).to be_nil
  end
end
