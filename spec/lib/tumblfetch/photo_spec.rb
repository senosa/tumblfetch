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

describe Tumblfetch::Photo, '#download' do
  before do
    @photos = [
      {'original_size' => {'url' => 'https://raw.githubusercontent.com/wiki/senosa/tumblfetch/images/under500.jpg', 'width' => 480}}
    ]
    @post = {
      'id' => 123,
      'link_url' => 'TheURL',
      'photos' => @photos
    }
    @p = Tumblfetch::Photo.new(post: @post, photoset_idx: 0)
  end
  subject { @p.download }
  it { should have(1).result }
  its(:first) { should include 'success' }
  it 'should download from @original_url' do
    subject
    expect(File.exist?('123.jpg')).to be_true
  end

  context 'when open(@original_url) raise exception' do
    before do
      @photos = [
        {'original_size' => {'url' => 'invalid_url', 'width' => 480}}
      ]
      @post = {
        'id' => 123,
        'link_url' => 'TheURL',
        'photos' => @photos
      }
      @p = Tumblfetch::Photo.new(post: @post, photoset_idx: 0)
    end
    its(:first) { should include 'fail' }
    it 'should NOT create needless image file' do
      subject
      expect(File.exist?('123.jpg')).to be_false
    end
  end

  context 'photoset' do
    before do
      @photos = [
        {'original_size' => {'url' => 'https://raw.githubusercontent.com/wiki/senosa/tumblfetch/images/under500.jpg', 'width' => 480}},
        {'original_size' => {'url' => '2ndURL', 'width' => 480}}
      ]
      @post = {
        'id' => 456,
        'link_url' => 'TheURL',
        'photos' => @photos
      }
      @p = Tumblfetch::Photo.new(post: @post, photoset_idx: 0)
    end
    it 'should create correct filename' do
      subject
      expect(File.exist?('456_0.jpg')).to be_true
    end
  end
end
