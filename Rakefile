require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rspec/core'
require 'rdoc/task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb'].uniq
  spec.rspec_opts = '--format documentation'
end

RDoc::Task.new(:doc) do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include %w(README.rdoc lib)
end

RuboCop::RakeTask.new(:cop)
