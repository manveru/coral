module Coral
  class Index < ::Hash
    attr_reader :reef, :file

    def initialize(local_reef)
      @reef = local_reef
      @file = Pathname(reef) + 'index.yaml'

      replace YAML.load_file(file) if file.exist?
    end

    def to_hash
      {}.merge!(self)
    end

    def find_repo(repo_name)
      key?(repo_name) and "#{repo_name}/#{self[repo_name].first}"
    end

    def add(remote)
      (self[remote.project] ||= []) << remote.user
      dump!
    end

    def dump!
      File.open(file, 'w+'){|io| io.puts(self.to_hash.to_yaml) }
    end

    def reindex
      index = {}

      reef.chdir do
        Pathname.glob('*/*').each do |dir|
          repo, branch = dir.split
          (index[repo] ||= []) << branch
        end
      end

      replace(index)
    end

    def reindex!
      reindex
      dump!
    end

    def coral_path(polyp)
      reef + polyp.project + polyp.user
    end
  end
end
