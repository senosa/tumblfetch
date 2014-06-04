require 'spec_helper'
require 'tumblfetch'

describe Tumblfetch::Fetcher, '#analyze' do
  before do
    @f = Tumblfetch::Fetcher.new('dummy_conf')
    @f.stub(:create_posts_list).and_return { [] }
  end

  subject { @f.analyze }
  it { should be_a Hash }
  it { should include :photos }
  it { should include :posts }
end

describe Tumblfetch::Fetcher, '#download' do
  before do
    @f = Tumblfetch::Fetcher.new('dummy_conf')
    @p = double 'photo'
    @p.stub(:download).and_return { ['success'] }
    @f.photos = [@p]
  end

  subject { @f.download }
  its([:success]) { should eq 1 }
  its([:fails]) { should eq [] }

  context 'when 2 photos in @photos' do
    before { @f.photos << @p }
    its([:success]) { should eq 2 }
  end

  context 'when Photo#download return fail' do
    before { @p.stub(:download).and_return { 'fail' } }

    its([:success]) { should eq 0 }
    its([:fails]) { should eq ['fail'] }
  end
end

describe Tumblfetch::Fetcher, '#create_posts_list' do
  before do
    Tumblr::Client.any_instance.stub(:posts).and_return { {'posts' => []} }
    config = {'blog_name' => 'tt', 'last_fetch_id' => nil}
    @f = Tumblfetch::Fetcher.new(config)
  end

  subject { @f.send(:create_posts_list) }
  it { should be_a Array }
  it { should be_empty }

  context 'when 2 posts and first fetch' do
    before do
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 0})
        .and_return do
          {'posts' => [
            {'id' => 123, 'photos' => []},
            {'id' => 456, 'photos' => []}
            ]
          }
        end
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 20})
        .and_return { {'posts' => []} }
    end
    it { should have(2).posts }
  end

  context 'when 1 New post in 3 posts' do
    before do
      @f.config['last_fetch_id'] = :the_last
      Tumblr::Client.any_instance.stub(:posts)
        .and_return do
          {'posts' => [
            {'id' => 987, 'photos' => []},
            {'id' => :the_last},
            {'id' => 321}
            ]
          }
        end
    end
    it { should have(1).post }
  end

  context 'when last fetch post is in second response' do
    before do
      @f.config['last_fetch_id'] = :the_last
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 0})
        .and_return do
          {'posts' => [
            {'id' => 99, 'photos' => []}
            ]
          }
        end
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 20})
        .and_return do
          {'posts' => [
            {'id' => 88, 'photos' => []},
            {'id' => 77, 'photos' => []},
            {'id' => :the_last}
            ]
          }
        end
    end
    it { should have(3).posts }
  end
end

describe Tumblfetch::Fetcher, '#create_photos_list' do
  before do
    Tumblfetch::Photo.stub(:new) { double 'photo' }
    @f = Tumblfetch::Fetcher.new('dummy_conf')
    @posts = []
  end

  subject { @f.send(:create_photos_list, @posts) }
  it { should be_a Array }

  context 'when 1 photo in 1 post' do
    before { @posts << {'id' => 987, 'photos' => ['photo1']} }
    it { should have(1).photo }
  end

  context 'when 2 photos in 1 post(photoset)' do
    before { @posts << {'id' => 987, 'photos' => ['photo1', 'photo2']} }
    it { should have(2).photos }
  end

  context 'when 3 photos in 2 posts' do
    before do
      @posts <<  {'id' => 987, 'photos' => ['photo1']}
      @posts <<  {'id' => 654, 'photos' => ['photo2', 'photo3']}
    end
    it { should have(3).photos }
  end
end
