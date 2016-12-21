require 'fileutils'
require 'cucumber'
require 'cucumber/rake/task'
require 'rubocop/rake_task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

namespace :spec do
  desc "Clean up rbx compiled files and run cucumber tests"
  Cucumber::Rake::Task.new(:ci) do
    Dir.glob("**/*.rbc").each { |f| FileUtils.rm_f(f) }
  end
end

RuboCop::RakeTask.new
