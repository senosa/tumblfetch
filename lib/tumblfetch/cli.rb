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
      unless File.exist?('.fetch')
        say "`.fetch` can't be found. Run `tumblfetch init` for generating it.", :red
        return
      end

      # credentials check
      config = YAML.load_file('.fetch')
      if config['consumer_key'].nil? || config['consumer_secret'].nil? || config['oauth_token'].nil? || config['oauth_token_secret'].nil?
        say "`.fetch` doesn't contain credentials.", :red
        say "Get your own credentials on (http://www.tumblr.com/oauth/register), ", :red
        say "and set to `.fetch`.", :red
        return
      end

      say "Start fetching."
      f = Tumblfetch::Fetcher.new(config)
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
        result[:fails].each {|fail| say "  #{fail}", :red }
      end
      config['last_fetch_id'] = result[:last_fetch_id]
      open('.fetch', 'w') {|file| file.write(config.to_yaml) }
    end

    def self.source_root
      File.dirname(__FILE__)
    end

  end
end
