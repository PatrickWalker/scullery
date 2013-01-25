require File.expand_path("../lib/scullery/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "Scullery"
  s.version     = Scullery::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Barry Miller", "Darren Thompson","Graeme Thompson","Neil McCaughley", "Patrick Walker"]
  s.email       = ["bpatrick.walker@gmail.com"]
  s.homepage    = "https://github.com/patrickwalker/scullery"
  s.summary     = "Backup and Restore functionality for Chef"
  s.description = "This Gem offers functionality to store all the information in Chef within source and restore from it."

  s.required_rubygems_version = ">= 1.3.6"

  # lol - required for validation
  s.rubyforge_project         = "Scullery"

  # If you have other dependencies, add them here
    s.add_dependency "net-scp", "~> 1.0"
    s.add_dependency "net-ssh", "~> 2.6"
    s.add_dependency "git", "~> 1.2"
    s.add_dependency "json", "~> 1.6"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'

  # If you need an executable, add it here
   s.bindir = 'bin'
   s.executables = ["scullery_monitor"]


end