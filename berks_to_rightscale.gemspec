Gem::Specification.new do |gem|
  gem.name = "berks_to_rightscale"
  gem.version = "0.0.4"
  gem.homepage = "https://github.com/rgeyer/berks_to_rightscale"
  gem.license = "MIT"
  gem.summary = %Q{A commandline utility which will collect cookbooks defined by berkshelf, compress them, and store them in S3 to be fetched by RightScale}
  gem.description = gem.summary
  gem.email = "ryan.geyer@rightscale.com"
  gem.authors = ["Ryan J. Geyer"]
  gem.executables << 'berks_to_rightscale'

  gem.add_dependency('berkshelf', '~> 2.0.6')
  gem.add_dependency('chef', '~> 11.4.2')
  gem.add_dependency('thor', '~> 0.18.1')
  gem.add_dependency('fog', '~> 1.12.1')

  gem.files = Dir.glob("{lib,bin}/**/*") + ["LICENSE.txt", "README.rdoc"]
end
