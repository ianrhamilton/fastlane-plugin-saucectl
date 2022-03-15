require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

desc "Initialize git submodules"
task :init do
  system "git submodule init"
  system "git submodule update"
end

task(default: [:init, :spec])
