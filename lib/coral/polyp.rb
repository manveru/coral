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

    def self.parse(string)
      case string
      when /^(.+)\/(.+)$/ # "project/user"
        new(project = $1, user = $2)
      when /^(.+)-(.+)$/ # "user-project"
        new(project = $2, user = $1)
      else
        raise("I don't know how to parse %p" % string)
      end
    end

    def self.parse_uri(remote_uri)
      case remote_uri
      when /^git@github\.com:(.+)\/(.+)\.git$/
      when /github.com\/(.+)\/(.+)\.git$/
      else
        raise("I don't know how to organize repos like %p" % remote_uri)
      end

      new(project = $2, user = $1)
    end
  end
end
