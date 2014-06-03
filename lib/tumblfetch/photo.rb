require 'open-uri'
require 'fileutils'

module Tumblfetch
  class Photo
    attr_reader :post_id, :link_url, :photoset_idx, :original_width, :original_url
    def initialize(post:, photoset_idx:)
      @post_id = post['id']
      @link_url = post['link_url']
      @photoset_idx = post['photos'].size == 1 ? nil : photoset_idx
      @original_width = post['photos'][photoset_idx]['original_size']['width']
      @original_url = post['photos'][photoset_idx]['original_size']['url']
    end

    def download
      result = []
      extname = File.extname(@original_url)
      filename = @post_id.to_s
      filename << "_#{@photoset_idx}" if @photoset_idx
      filename << extname

      begin
        open(filename, "wb") do |file|
          open(@original_url) do |data|
            file.write(data.read)
          end
        end
        result << 'success'
      rescue
        FileUtils.rm(filename)
        # pp $!
        result << 'fail'
      end

      result
    end

  end
end
