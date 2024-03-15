# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'infobar'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     'Gem to display information about computations.'
  description 'This gem displays progress of computations and additional information to the terminal.'
  module_type :class
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage', '.rvmrc',
    '.AppleDouble', 'tags', '.byebug_history', '.DS_Store', 'errors.lst', '.tool-versions'
  readme      'README.md'
  title       "#{name.camelize}"

  required_ruby_version '>= 2.3'
  dependency 'tins',           '~> 1.0', '>= 1.28.0'
  dependency 'term-ansicolor', '~> 1.4'
  dependency 'complex_config', '~> 0.10'
  dependency 'more_math'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'debug'
  development_dependency 'all_images'
end

task :default => :spec
