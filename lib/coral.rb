require 'yaml'
require 'pathname'
require 'fileutils'

module Coral
  LocalReef = Pathname('~/.coral').expand_path
  LocalReef.mkpath

  autoload :Runner, 'coral/runner'
  autoload :Polyp,  'coral/polyp'
  autoload :Index,  'coral/index'

  def self.repos
    index.keys
  end

  def self.index
    @index ||= Index.new(LocalReef)
  end

  def self.find(repo_name)
    index.find_repo(repo_name)
  end

  def self.activate(coral_dir)
    coral_dir = LocalReef + coral_dir unless coral_dir.absolute?
    coral_dir += 'lib' unless coral_dir.basename.to_s == 'lib'

    raise("Coral misses indexed %p" % coral_dir) unless coral_dir.exist?

    $LOAD_PATH.unshift(coral_dir.expand_path.to_s)
  end
end

require 'coral/custom_require' unless 'coral' == File.basename($0)
