require 'tumblfetch/version'
require 'tumblfetch/photo'
require 'tumblr_client'
require 'yaml'

module Tumblfetch
  class Fetcher
    attr_accessor :config, :photos
    def initialize(config)
      @config = config
      @photos = nil
    end

    def analyze
      posts = create_posts_list
      @photos = create_photos_list(posts)

      {photos: photos.size, posts: posts.size}
    end

    def download
      result = {success: 0, fails: []}
      @photos.each do |photo|
        r = photo.download
        if r == ['success']
          result[:success] += 1
        else
          result[:fails] << r
        end
      end
      result
    end

    private
    def create_posts_list
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
      posts
    end

    def create_photos_list(posts)
      photos = []
      posts.each do |post|
        post['photos'].each_with_index do |photo, idx|
          photos << Tumblfetch::Photo.new(post: post, photoset_idx: idx)
        end
      end
      photos
    end
    
  end
end
