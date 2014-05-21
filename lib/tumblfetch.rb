require "tumblfetch/version"

module Tumblfetch
  SETTINGS_TEMPLATE =<<-EOS
base-hostname: testing-fetcher.tumblr.com
last-fetch-id: nil
  EOS

  def self.write_settings_template_to(io)
    io.puts SETTINGS_TEMPLATE
  end
end
