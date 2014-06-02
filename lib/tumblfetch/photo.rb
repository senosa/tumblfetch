module Tumblfetch
  class Photo
    attr_reader :post_id, :link_url, :photoset_idx, :original_width, :original_url
    def initialize(post:, photoset_idx:)
      @post_id = post['id']
      @link_url = post['link_url']
      @photoset_idx = photoset_idx
      @original_width = post['photos'][photoset_idx]['original_size']['width']
      @original_url = post['photos'][photoset_idx]['original_size']['url']
    end
  end
end
