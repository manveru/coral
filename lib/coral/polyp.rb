require 'uri'

module Coral
  # While a coral head appears to be a single organism, it is actually a head
  # of many individual, yet genetically identical, polyps.
  class Polyp
    attr_reader :project, :user

    def initialize(project, user)
      @project = project
      @user    = user
    end

    def self.parse(arg)
      case arg
      when /^git@github\.com:(.+)\/(.+)\.git$/
      when /github.com\/(.+)\/(.+)\.git$/
      when /^(\w+)[\/-](\w+)$/ # user/project or user-project
      else
        raise("I don't know how to get repos like %p" % arg)
      end

      new(project = $2, user = $1)
    end

    def to_uri
      case `git config github.user`.strip
      when user
        "git@github.com:#{user}/#{project}.git"
      else
        URI("git://github.com/#{user}/#{project}.git")
      end
    end
  end
end
