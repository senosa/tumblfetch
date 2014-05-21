require 'thor'
require 'tumblfetch'

class CLI < Thor
  SETTINGS_EXIST_MSG =<<-EOS
`.tumblfetch` already exists in this directory.
  EOS

  SETTINGS_GENERATED_MSG =<<-EOS
`.tumblfetch` has been placed in this directory.
  EOS

  desc 'version', 'Print a version'
  def version
    puts Tumblfetch::VERSION
  end

  desc 'init', 'Generate a .tumblfetch'
  def init
    if File.exist?('./.tumblfetch')
      $stderr.puts(SETTINGS_EXIST_MSG)
    else
      File.open('./.tumblfetch', 'w') do |file|
        Tumblfetch.write_settings_template_to(file)
      end
      puts(SETTINGS_GENERATED_MSG)
    end
  end
end
