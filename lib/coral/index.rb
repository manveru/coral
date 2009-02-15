module Coral
  class Index < ::Hash
    attr_reader :reef, :file

    def initialize(local_reef, retrying = false)
      @reef = local_reef
      @file = Pathname(reef) + 'index.yaml'

      load!(file)
    rescue ArgumentError => error
      raise error if retrying
      reindex!
      retrying = true
      retry
    end

    def to_hash
      {}.merge!(self)
    end

    def find_repo(repo_name)
      return unless key?(repo_name)
      "#{repo_name}/#{self[repo_name].first}"
    end

    def add(remote)
      (self[remote.project] ||= []) << remote.user
      dump!
    end

    def dump!
      File.open(file, 'w+'){|io|
        hash = {}
        each{|k,v| hash[k.to_s] = v.map{|vv| vv.to_s }}
        io.print(hash.to_yaml)
      }
    end

    # seems like we discovered a bug in YAML...
    def load!(file)
      hash = {}
      YAML.load_file(file).each do |k, v|
        hash[Pathname(k)] = v.map{|vv| Pathname(vv) }
      end
      replace(hash)
    end

    def reindex
      index = {}

      Dir.chdir(reef) do
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
