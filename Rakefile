# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w{--color}
end
Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = %w{--color --format pretty}
end

task :test => [:spec,:cucumber]
task :default => :test

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "agent_fix"
  gem.homepage = "http://github.com/connamara/agent_fix"
  gem.license = "GPL"
  gem.summary = %Q{Agent framework for FIX messages}
  gem.description = %Q{Interact with FIX connections to send, receive, and inspect messages in cucumber}
  gem.email = "info@connamara.com"
  gem.authors = ["Matt Lane","Chris Busbey"]
  # dependencies defined in Gemfile
end


