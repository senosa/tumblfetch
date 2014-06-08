require 'thor'
require 'tumblfetch'
require 'yaml'

module Tumblfetch
  class CLI < Thor
    include Thor::Actions

    desc 'version', 'Print a version'
    def version
      say Tumblfetch::VERSION
    end

    desc 'init', 'Generate a .fetch'
    def init
      if File.exist?('.fetch')
        say "`.fetch` already exists in this directory.", :red
        return
      end

      copy_file 'templates/.fetch', '.fetch'

      if File.exist?(File.join(ENV['HOME'], '.tumblr'))
        tumblr_client_config = YAML.load_file(File.join(ENV['HOME'], '.tumblr'))
        config = YAML.load_file('.fetch').merge(tumblr_client_config)
        open('.fetch', 'w') {|file| file.write(config.to_yaml) }
      end
    end

    desc 'fetch', 'Fetch'
    def fetch
      return unless dot_tumblr_exist?

      unless File.exist?('.fetch')
        say "`.fetch` can't be found. Run `tumblfetch init` for generating it.", :red
        return
      end

      say "Start fetching."

      f = Tumblfetch::Fetcher.new(YAML.load_file('.fetch'))
      result = f.analyze

      if result[:posts] == 0
        say "No new post."
        return
      end

      say "#{result[:photos]} photos (in #{result[:posts]} posts) are found."

      result = f.download

      say "#{result[:success]} photos are downloaded.", :green
      unless result[:fails].empty?
        say "#{result[:fails].size} photos can't download.", :red
        result[:fails].each do |f|
          say "  #{f[0]}", :red
        end
      end
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
