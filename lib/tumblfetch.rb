require 'tumblfetch/version'
require 'tumblfetch/photo'
require 'tumblr_client'

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
      result = {success: 0, fails: [], last_fetch_id: nil}
      @photos.each do |photo|
        r = photo.download
        if r == ['success']
          result[:success] += 1
        else
          result[:fails] << r
        end
      end
      result[:last_fetch_id] = @photos.first.post_id
      result
    end

    private
    def create_posts_list
      Tumblr.configure do |conf|
        conf.consumer_key = @config['consumer_key']
        conf.consumer_secret = @config['consumer_secret']
        conf.oauth_token = @config['access_token']
        conf.oauth_token_secret = @config['access_token_secret']
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
          idx = nil if idx == 0
          photos << Tumblfetch::Photo.new(
            post_id: post['id'],
            link_url: post['source_url'],
            photoset_idx: idx,
            original_url: photo['original_size']['url'],
            original_width: photo['original_size']['width'],
            alt_1_url: photo['alt_sizes'][1]['url']
          )
        end
      end
      photos
    end

  end
end
