require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'rubygems'
require 'prawn'
require 'barby'

# local version number file
require 'lib/version'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs for the plugin'
Spec::Rake::SpecTask.new(:spec) do |t|
  puts "KillBill specs, versão #{Riopro::KillBill::VERSION}"
  puts "Running on Ruby Version: #{RUBY_VERSION}"
  puts "Running prawn version #{Prawn::VERSION}"
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the plugin'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'KillBill'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
