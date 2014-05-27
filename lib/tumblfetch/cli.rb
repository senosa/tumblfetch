require 'thor'
require 'tumblfetch'

module Tumblfetch
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    desc 'version', 'Print a version'
    def version
      say Tumblfetch::VERSION
    end

    desc 'init', 'Generate a .tumblfetch'
    def init
      unless File.exist?(File.join(ENV['HOME'], '.tumblr'))
        say "`~/.tumblr` can't be found. Run `tumblr` for generating it.", :red
        say "For details, see https://github.com/tumblr/tumblr_client#the-irb-console", :red
        return
      end

      if File.exist?('.tumblfetch')
        say "`.tumblfetch` already exists in this directory.", :red
      else
        copy_file 'templates/.tumblfetch', '.tumblfetch'
      end
    end
  end
end
