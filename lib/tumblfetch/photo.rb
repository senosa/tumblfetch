require 'open-uri'
require 'fileutils'
require 'fastimage'
require 'webrick/httputils'
require 'open_uri_redirections'

module Tumblfetch
  class Photo
    attr_reader :post_id, :link_url, :photoset_idx, :original_width, :original_url
    def initialize(post:, photoset_idx:)
      @post_id = post['id']
      @link_url = post['link_url']
      @photoset_idx = post['photos'].size == 1 ? nil : photoset_idx
      @original_width = post['photos'][photoset_idx]['original_size']['width']
      @original_url = post['photos'][photoset_idx]['original_size']['url']
      @alt_1_url = post['photos'][photoset_idx]['alt_sizes'][1]['url']
    end

    def download
      # strategy1
      # target_url = link_url_is_real_original? ? @link_url : @original_url

      target_url = strategy2

      extname = File.extname(target_url)
      filename = @post_id.to_s
      filename << "_#{@photoset_idx}" if @photoset_idx
      filename << extname

      result = []
      begin
        open(filename, "wb") do |file|
          open(WEBrick::HTTPUtils.escape(target_url), :allow_redirections => :safe) do |data|
            file.write(data.read)
          end
        end
        result << 'success'
      rescue
        FileUtils.rm(filename)
        result << "#{@post_id}: #{$!.message}"
      end

      result
    end

    def strategy2
      target_url = nil
      targets = [@link_url, @original_url, @alt_1_url]
      targets.each do |url|
        begin
          target_url = url if FastImage.size(url)
        rescue
        end
        break if target_url
      end
      # target_url ||= @alt_0_url # It is equal @original_url
      target_url ||= @original_url
    end

    private
    def link_url_is_real_original?
      return false unless @original_width == 1280
      return false unless @link_url =~ /.+(.jp(e)*g|.png|.gif)\z/
      real_original_size = FastImage.size(@link_url)
      return false unless real_original_size
      return false if real_original_size.first <= 1280
      true
    end

  end
end
