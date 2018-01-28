require "bundler/gem_tasks"
require "rake/testtask"

task :default => :test
Rake::TestTask.new

task :embed_usage do
  sh "bin/markdown_usage -o bin/markdown_usage -s '`markdown_usage` Script' README.md"
end
