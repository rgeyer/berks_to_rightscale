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
require 'rake/clean'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

desc 'Package gem'
gemtask = Gem::PackageTask.new(Gem::Specification.load('berks_to_rightscale.gemspec')) do |package|
  package.package_dir = 'pkg'
  package.need_zip = true
  package.need_tar = true
end

directory gemtask.package_dir

CLEAN.include(gemtask.package_dir)

require 'yard'
YARD::Rake::YardocTask.new do |t|

end

# == Unit tests == #
spec_opts_file = "\"#{File.dirname(__FILE__)}/spec/spec.opts\""
RSPEC_OPTS = ['--options', spec_opts_file]

desc 'Run unit tests'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = RSPEC_OPTS
end

task :default => :spec
