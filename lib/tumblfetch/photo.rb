module Tumblfetch
  class Photo
    attr_reader :post_id, :link_url, :photoset_idx, :hash
    def initialize(post_id:, link_url:, photoset_idx:, hash:)
      @post_id = post_id
      @link_url = link_url
      @photoset_idx = photoset_idx
      @hash = hash
    end
  end
end
