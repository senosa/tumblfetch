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
      'photos' => @photos
    }
  end
  subject { Tumblfetch::Photo.new(post: @post, photoset_idx: 0).download }
  it { should have(1).result }
  its(:first) { should include 'success' }
  it 'should download from @original_url' do
    subject
    expect(File.exist?('123.jpg')).to be_true
    expect(FastImage.size('123.jpg')).to eq [480, 480]
  end

  context 'when open(@original_url) raise exception' do
    before { @photos[0]['original_size']['url'] = 'invalid_url' }
    its(:first) { should include '123: No such file or directory @ rb_sysopen - invalid_url' }
    it 'should NOT create needless image file' do
      subject
      expect(File.exist?('123.jpg')).to be_false
    end
  end

  context 'when photoset' do
    before { @photos << {'2ndPhoto' => nil} }
    it 'should create correct filename' do
      subject
      expect(File.exist?('123_0.jpg')).to be_true
    end
  end

  context 'when link_url is REAL original' do
    before do
      @photos = [
        {'original_size' => {'url' => 'NotRealOriginalURL', 'width' => 1280}}
      ]
      @post = {
        'id' => 123,
        'link_url' => 'https://raw.githubusercontent.com/wiki/senosa/tumblfetch/images/over1280.jpeg',
        'photos' => @photos
      }
    end
    it 'should download from link_url' do
      subject
      expect(File.exist?('123.jpeg')).to be_true
      expect(FastImage.size('123.jpeg')).to eq [1300, 500]
    end
  end
end
