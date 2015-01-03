require 'open-uri'
require 'fileutils'
require 'fastimage'
require 'webrick/httputils'
require 'open_uri_redirections'

module Tumblfetch
  class Photo
    attr_accessor :post_id
    def initialize(post_id:, link_url:, photoset_idx:, original_url:, original_width:, alt_1_url:)
      @post_id = post_id
      @link_url = link_url
      @photoset_idx = photoset_idx
      @original_width = original_width
      @original_url = original_url
      @alt_1_url = alt_1_url
      @target_url = nil
    end

    def target_url
      @target_url ||= strategy2
    end

    def filename
      filename = @post_id.to_s
      filename << "_#{@photoset_idx}" if @photoset_idx
      filename << '.' + FastImage.type(target_url).to_s
    end

    def download
      target_url = strategy2
      filename = self.filename

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

    private
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
      target_url ||= @original_url
    end

  end
end
