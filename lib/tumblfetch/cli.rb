require 'thor'
require 'tumblfetch'

module Tumblfetch
  class CLI < Thor
    include Thor::Actions

    desc 'version', 'Print a version'
    def version
      say Tumblfetch::VERSION
    end

    desc 'init', 'Generate a .tumblfetch'
    def init
      return unless dot_tumblr_exist?

      if File.exist?('.tumblfetch')
        say "`.tumblfetch` already exists in this directory.", :red
        return
      end

      copy_file 'templates/.tumblfetch', '.tumblfetch'
    end

    desc 'fetch', 'Fetch'
    def fetch
      return unless dot_tumblr_exist?

      unless File.exist?('.tumblfetch')
        say "`.tumblfetch` can't be found. Run `tumblfetch init` for generating it.", :red
        return
      end

      say "Start fetching."

      f = Tumblfetch::Fetcher.new
      result = f.analyze

      if result[:posts] == 0
        say "No new post."
        return
      end

      say "#{result[:photos]} photos (in #{result[:posts]} posts) are found."

      f.download
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    no_tasks do
      def dot_tumblr_exist?
        if File.exist?(File.join(ENV['HOME'], '.tumblr')) then true
        else
          say "`~/.tumblr` can't be found. Run `tumblr` for generating it.", :red
          say "For details, see https://github.com/tumblr/tumblr_client#the-irb-console", :red
          false
        end
      end
    end

  end
end
