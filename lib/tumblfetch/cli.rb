require 'thor'
require 'tumblfetch'

class CLI < Thor
  desc 'version', 'Print a version'
  def version
    puts Tumblfetch::VERSION
  end

  desc 'init', 'Generate a .tumblfetch'
  def init
    File.open('./.tumblfetch', 'w') do |file|
      Tumblfetch.write_settings_template_to(file)
    end
  end
end
