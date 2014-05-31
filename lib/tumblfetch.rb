require 'tumblfetch/version'
require 'tumblr_client'
require 'yaml'

module Tumblfetch
  class Fetcher
    attr_writer :config
    def initialize
      @config = YAML.load_file('.tumblfetch')
    end

    def analyze
      configuration = YAML.load_file(File.join(ENV['HOME'], '.tumblr'))
      Tumblr.configure do |config|
        Tumblr::Config::VALID_OPTIONS_KEYS.each do |key|
          config.send(:"#{key}=", configuration[key.to_s])
        end
      end
      client = Tumblr::Client.new

      posts = []
      offset = 0
      catch :exit do
        loop do
          resp = client.posts(@config['blog_name'], type: 'photo', offset: offset)
          throw :exit if resp['posts'].empty?
          resp['posts'].each do |post|
            throw :exit if post['id'] == @config['last_fetch_id']
            posts << post
          end
          offset += 20
        end
      end

      photos = []
      posts.each do |post|
        post['photos'].each do |photo|
          photos << photo
        end
      end
      
      {photos: photos.size, posts: posts.size}
    end

    def download
    end
  end
end
