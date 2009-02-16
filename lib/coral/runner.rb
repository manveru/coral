module Coral
  module Runner
    attr_accessor :noop, :verbose
    module_function :noop, :noop=, :verbose, :verbose=
    module_function

    def clone(arg)
      polyp = Polyp::parse(arg)
      coral_path = Coral.index.coral_path(polyp)

      add_remote(polyp) if sh('git', 'clone', polyp.to_uri, coral_path)
    end

    def list
      puts Coral.repos.sort.join(", ")
    end

    def move(repo, name = nil)
      source = File.expand_path(repo)
      source_config = "#{source}/.git/config"

      unless File.exists? source_config
        abort "Failed:  directory #{source.inspect} doesn't seem like a git repository"
      end
      # get the URL of the remote named "origin"
      url = `git config --file #{source_config.inspect} remote.origin.url`.chomp
      polyp = name ? Polyp::parse(name) : Polyp::parse_uri(url)
      target = Coral.index.coral_path(polyp)

      if File.exists? target
        abort "Aborted:  target #{target.inspect} already exists"
      end
      # move the repo to the new location
      FileUtils.mkdir_p(File.dirname(target), fileutils_options)
      FileUtils.mv(source, target, fileutils_options)

      add_remote(polyp)
      puts "Repo #{source.inspect} joined the coral colony at #{target.inspect}"
    end

    def update(repo)
      dir = Coral.find(repo)
      abort("Failed: couldn't find %p in Coral" % repo) unless dir

      Dir.chdir(LocalReef + dir){ sh('git', 'pull') }
    end

    def reindex
      Coral.index.reindex!
      puts("Coral index written to %p" % Coral.index.file)
    end

    def sh(*args)
      args = args.map{|arg| arg.to_s }
      puts args.join(' ') if verbose
      return system(*args) unless noop
      true
    end

    def add_remote(remote)
      Coral.index.add(remote) unless noop
    end
  end
end
