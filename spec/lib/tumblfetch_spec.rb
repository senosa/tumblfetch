require 'spec_helper'
require 'tumblfetch'

describe Tumblfetch::Fetcher, '#analyze' do
  before do
    path = File.dirname(__FILE__) + '/../../lib/tumblfetch/templates/.tumblfetch'
    FileUtils.cp(path, '.')
    subject.stub(:create_posts_list).and_return { [] }
  end

  it { expect(subject.analyze).to be_a Hash }
  it { expect(subject.analyze).to include :photos }
  it { expect(subject.analyze).to include :posts }

  after do
    FileUtils.remove('.tumblfetch')
  end
end

describe Tumblfetch::Fetcher, '#create_posts_list' do
  before do
    path = File.dirname(__FILE__) + '/../../lib/tumblfetch/templates/.tumblfetch'
    FileUtils.cp(path, '.')
    Tumblr::Client.any_instance.stub(:posts).and_return { {'posts' => []} }
  end

  it { expect(subject.send(:create_posts_list)).to be_a Array }

  context 'when No post' do
    it 'should return :posts == 0' do
      expect(subject.send(:create_posts_list).size).to eq 0
    end
  end

  context 'when 2 posts and first fetch' do
    it 'should return :posts == 2' do
      subject.config = {'blog_name' => 'tt','last_fetch_id' => nil }
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
      expect(subject.send(:create_posts_list).size).to eq 2
    end
  end

  context 'when 1 New post in 3 posts' do
    it 'should return :posts == 1' do
      subject.config = {'last_fetch_id' => :the_last}
      Tumblr::Client.any_instance.stub(:posts)
        .and_return do
          {'posts' => [
            {'id' => 987, 'photos' => []},
            {'id' => :the_last},
            {'id' => 321}
            ]
          }
        end
      expect(subject.send(:create_posts_list).size).to eq 1
    end
  end

  context 'when last fetch post is in second response' do
    it 'should return correct :posts' do
      subject.config = {'blog_name' => 'tt','last_fetch_id' => :the_last}
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
      expect(subject.send(:create_posts_list).size).to eq 3
    end
  end

  after do
    FileUtils.remove('.tumblfetch')
  end
end

describe Tumblfetch::Fetcher, '#create_photos_list' do
  before do
    path = File.dirname(__FILE__) + '/../../lib/tumblfetch/templates/.tumblfetch'
    FileUtils.cp(path, '.')
    Tumblfetch::Photo.stub(:new) { double 'photo' }
  end

  it { expect(subject.send(:create_photos_list, [])).to be_a Array }

  context '1 photo in 1 post' do
    let(:posts) do
      [
        {'id' => 987, 'photos' => ['photo1']}
      ]
    end

    it 'should return correct :photos' do
      expect(subject.send(:create_photos_list, posts).size).to eq 1
    end
  end

  context '2 photos in 1 post(photoset)' do
    let(:posts) do
      [
        {'id' => 987, 'photos' => ['photo1', 'photo2']}
      ]
    end

    it 'should return correct :photos' do
      expect(subject.send(:create_photos_list, posts).size).to eq 2
    end
  end

  context '3 photos in 2 posts' do
    let(:posts) do
      [
        {'id' => 987, 'photos' => ['photo1']},
        {'id' => 654, 'photos' => ['photo2', 'photo3']}
      ]
    end

    it 'should return correct :photos' do
      expect(subject.send(:create_photos_list, posts).size).to eq 3
    end
  end

  after do
    FileUtils.remove('.tumblfetch')
  end
end
