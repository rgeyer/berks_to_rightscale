# Copyright (c) 2012 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module BerksToRightscale
  class Cli < Thor

    desc "release PROJECTNAME RELEASENAME", "Releases the Cookbooks specified by a Berksfile or Berksfile.lock as a [PROJECTNAME]/[RELEASENAME].tar.gz file to the specified location."
    option :except, :desc => "Exclude cookbooks that are in these groups.", :type => :array
    option :only, :desc => "Only cookbooks that are in these groups.", :type => :array
    option :berksfile, :banner => "PATH", :desc => "Path to a Berksfile to operate off of.", :default => File.join(Dir.pwd, ::Berkshelf::DEFAULT_FILENAME)
    option :force, :desc => "Forces the current release with the same name to be overwritten.", :type => :boolean
    option :no_cleanup, :desc => "Skips the removal of the cookbooks directory and the generated tar.gz file", :type => :boolean
    option :provider, :desc => "A provider listed by list_destinations which will be used to upload the cookbook release", :required => true
    option :container, :desc => "The name of the storage container to put the release file in.", :required => true
    def release(projectname, releasename)
      output_path = ::File.join(Dir.pwd, "cookbooks")
      sym_options = {}
      options.each{|k,v| sym_options[k.to_sym] = v }
      final_opts = {:path => output_path, :force => false, :no_cleanup => false}.merge(sym_options)
      tarball = "#{releasename}.tar.gz"
      file_key = "#{projectname}/#{tarball}"

      tarball_path = ::File.join(Dir.pwd, tarball)

      fog_params = { :provider => final_opts[:provider] }

      fog = ::Fog::Storage.new(fog_params)

      unless container = fog.directories.all.detect {|cont| cont.key == final_opts[:container]}
        raise "There was no container named #{final_opts[:container]} for provider #{final_opts[:provider]}"
      end

      if container.files.all.detect {|file| file.key == file_key} && !final_opts[:force]
        raise "There is already a released named #{releasename} for the project #{projectname}.  If you want to overwrite it, specify the --force flag"
      end

      berksfile = ::Berkshelf::Berksfile.from_file(final_opts[:berksfile])
      berksfile.install(final_opts)

      meta = ::Chef::Knife::CookbookMetadata.new
      meta.config[:all] = true
      meta.config[:cookbook_path] = output_path
      meta.run

      puts "Creating a tarball containing the specified cookbooks"
      `tar -C #{output_path} -zcvf #{tarball_path} . 2>&1`

      file = File.open(tarball_path, 'r')
      fog_file = container.files.create(:key => file_key, :body => file, :acl => 'public-read')
      fog_file.save
      file.close

      puts "Released file can be found at #{fog_file.public_url}"

      # Cleanup
      unless final_opts[:no_cleanup]
        FileUtils.rm tarball if File.exist? tarball
        FileUtils.rm_rf output_path if File.directory? output_path
      end
    end

    desc "list_destinations", "Lists all possible release locations.  Basically a list of supported fog storage providers"
    def list_destinations
      puts ::Fog::Storage.providers
    end
  end
end