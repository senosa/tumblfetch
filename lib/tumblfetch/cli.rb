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
      if File.exist?(File.join(ENV['HOME'], '.tumblr'))
        if File.exist?('.tumblfetch')
          say "`.tumblfetch` already exists in this directory.", :red
        else
          File.open('.tumblfetch', 'w') do |file|
            Tumblfetch.write_settings_template_to(file)
          end
          say "`.tumblfetch` has been placed in this directory.", :green
        end
      else
        say "`~/.tumblr` can't be found. Run `tumblr` for generating it.", :red
        say "For details, see https://github.com/tumblr/tumblr_client#the-irb-console", :red
      end
    end
  end
end
