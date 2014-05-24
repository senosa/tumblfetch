require 'thor'
require 'tumblfetch'

class CLI < Thor
  SETTINGS_EXIST_MSG =<<-EOS
`.tumblfetch` already exists in this directory.
  EOS

  SETTINGS_GENERATED_MSG =<<-EOS
`.tumblfetch` has been placed in this directory.
  EOS

  EXECUTE_TUMBLR_MSG =<<-EOS
`~/.tumblr` can't be found. Run `tumblr` for generating it.
For details, see https://github.com/tumblr/tumblr_client#the-irb-console
  EOS

  desc 'version', 'Print a version'
  def version
    puts Tumblfetch::VERSION
  end

  desc 'init', 'Generate a .tumblfetch'
  def init
    if File.exist?(File.join(ENV['HOME'], '.tumblr'))
      if File.exist?('./.tumblfetch')
        $stderr.puts(SETTINGS_EXIST_MSG)
      else
        File.open('./.tumblfetch', 'w') do |file|
          Tumblfetch.write_settings_template_to(file)
        end
        puts(SETTINGS_GENERATED_MSG)
      end
    else
      $stderr.puts(EXECUTE_TUMBLR_MSG)
    end
  end
end
