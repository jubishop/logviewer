require 'bundler/gem_tasks'

desc "Build the gem"
task :build do
  system "gem build logviewer.gemspec"
end

desc "Install the gem locally"
task :install => :build do
  system "gem install logviewer-#{LogViewer::VERSION}.gem"
end

desc "Push the gem to RubyGems"
task :push => :build do
  system "gem push logviewer-#{LogViewer::VERSION}.gem"
end

desc "Clean built gems"
task :clean do
  system "rm -f *.gem"
end

desc "Uninstall the gem"
task :uninstall do
  system "gem uninstall logviewer"
end

desc "Install dependencies"
task :deps do
  system "bundle install"
end

task :default => [:deps, :build]

# Load version for tasks that need it
require_relative 'lib/logviewer/version'