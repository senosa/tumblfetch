require 'thor'
require 'tumblfetch'

class CLI < Thor
  desc 'version', 'Print a version'
  def version
    puts Tumblfetch::VERSION
  end
end
