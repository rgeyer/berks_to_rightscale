Gem::Specification.new do |gem|
    gem.name = "berks_to_rightscale"
    gem.version = "0.0.0"
    gem.homepage = "https://github.com/rgeyer/berks_to_rightscale"
    gem.license = "MIT"
    gem.summary = %Q{berks_to_rightscale}
    gem.description = gem.summary
    gem.email = "ryan.geyer@rightscale.com"
    gem.authors = ["Ryan J. Geyer"]
    gem.executables << 'berks_to_rightscale'

    gem.add_dependency('trollop', '~> 1.16')
                          
    gem.files = Dir.glob("{lib,bin}/**/*") + ["LICENSE.txt", "README.rdoc"]
end
