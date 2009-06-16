#!/usr/bin/ruby

task :default => :spec

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.warning = true
  t.rcov = true
end
