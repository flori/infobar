# -*- encoding: utf-8 -*-
# stub: infobar 0.11.0 ruby lib

Gem::Specification.new do |s|
  s.name = "infobar".freeze
  s.version = "0.11.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "This gem displays progress of computations and additional information to the terminal.".freeze
  s.email = "flori@ping.de".freeze
  s.extra_rdoc_files = ["README.md".freeze, "lib/infobar.rb".freeze, "lib/infobar/counter.rb".freeze, "lib/infobar/display.rb".freeze, "lib/infobar/duration.rb".freeze, "lib/infobar/fancy_interface.rb".freeze, "lib/infobar/fifo.rb".freeze, "lib/infobar/frequency.rb".freeze, "lib/infobar/input_output.rb".freeze, "lib/infobar/message.rb".freeze, "lib/infobar/number.rb".freeze, "lib/infobar/rate.rb".freeze, "lib/infobar/spinner.rb".freeze, "lib/infobar/timer.rb".freeze, "lib/infobar/trend.rb".freeze, "lib/infobar/version.rb".freeze]
  s.files = ["CHANGES.md".freeze, "COPYING".freeze, "Gemfile".freeze, "README.md".freeze, "Rakefile".freeze, "infobar.gemspec".freeze, "lib/infobar.rb".freeze, "lib/infobar/counter.rb".freeze, "lib/infobar/display.rb".freeze, "lib/infobar/duration.rb".freeze, "lib/infobar/fancy_interface.rb".freeze, "lib/infobar/fifo.rb".freeze, "lib/infobar/frequency.rb".freeze, "lib/infobar/input_output.rb".freeze, "lib/infobar/message.rb".freeze, "lib/infobar/number.rb".freeze, "lib/infobar/rate.rb".freeze, "lib/infobar/spinner.rb".freeze, "lib/infobar/timer.rb".freeze, "lib/infobar/trend.rb".freeze, "lib/infobar/version.rb".freeze, "spec/config/infobar.yml".freeze, "spec/infobar/config_spec.rb".freeze, "spec/infobar/counter_spec.rb".freeze, "spec/infobar/display_spec.rb".freeze, "spec/infobar/duration_spec.rb".freeze, "spec/infobar/fifo_spec.rb".freeze, "spec/infobar/frequency_spec.rb".freeze, "spec/infobar/input_output_spec.rb".freeze, "spec/infobar/message_spec.rb".freeze, "spec/infobar/number_spec.rb".freeze, "spec/infobar/rate_spec.rb".freeze, "spec/infobar/spinner_spec.rb".freeze, "spec/infobar/timer_spec.rb".freeze, "spec/infobar/trend_spec.rb".freeze, "spec/infobar_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://github.com/flori/infobar".freeze
  s.rdoc_options = ["--title".freeze, "Infobar".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Gem to display information about computations.".freeze
  s.test_files = ["spec/infobar/config_spec.rb".freeze, "spec/infobar/counter_spec.rb".freeze, "spec/infobar/display_spec.rb".freeze, "spec/infobar/duration_spec.rb".freeze, "spec/infobar/fifo_spec.rb".freeze, "spec/infobar/frequency_spec.rb".freeze, "spec/infobar/input_output_spec.rb".freeze, "spec/infobar/message_spec.rb".freeze, "spec/infobar/number_spec.rb".freeze, "spec/infobar/rate_spec.rb".freeze, "spec/infobar/spinner_spec.rb".freeze, "spec/infobar/timer_spec.rb".freeze, "spec/infobar/trend_spec.rb".freeze, "spec/infobar_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 2.4".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<all_images>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1".freeze, ">= 1.28.0".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.11".freeze])
  s.add_runtime_dependency(%q<complex_config>.freeze, ["~> 0.22".freeze])
  s.add_runtime_dependency(%q<more_math>.freeze, [">= 0".freeze])
end
