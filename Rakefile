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
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "agent_fix"
  gem.homepage = "http://github.com/connamara/agent_fix"
  gem.license = "Connamara"
  gem.summary = %Q{Agent framework for FIX messages}
  gem.description = %Q{Interact with FIX connections to send, receive, and inspect messages in cucumber}
  gem.email = "support@connamara.com"
  gem.authors = ["Matt Lane"]
  # dependencies defined in Gemfile
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--color --format pretty --format junit --out features/reports}
end