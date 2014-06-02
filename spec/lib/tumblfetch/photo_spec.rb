require 'spec_helper'
require 'tumblfetch/photo'

describe Tumblfetch::Photo, '.new' do
  before do
    @photos = [
      {'original_size' => {'url' => '1stURL', 'width' => 1280}},
      {'original_size' => {'url' => '2ndURL', 'width' => 500}}
    ]
    @post = {
      'id' => 123,
      'link_url' => 'TheURL',
      'photos' => @photos
    }
  end

  subject { Tumblfetch::Photo.new(post: @post, photoset_idx: 0) }
  it { should be_a Tumblfetch::Photo }
  its(:post_id) { should eq 123 }
  its(:link_url) { should include 'TheURL' }
  its(:photoset_idx) { should eq 0 }
  its(:original_width) { should eq @photos[0]['original_size']['width'] }
  its(:original_url) { should eq @photos[0]['original_size']['url'] }

  context 'when photoset_idx = 1' do
    subject { Tumblfetch::Photo.new(post: @post, photoset_idx: 1) }
    its(:original_width) { should eq @photos[1]['original_size']['width'] }
  end

  context 'when link_url is nil' do
    before { @post['link_url'] = nil }

    subject { Tumblfetch::Photo.new(post: @post, photoset_idx: 0) }
    its(:link_url) { should be_nil }
  end
end
