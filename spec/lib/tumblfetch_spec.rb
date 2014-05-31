require 'spec_helper'
require 'tumblfetch'

describe Tumblfetch::Fetcher, '#analyze' do
  before do
    path = File.dirname(__FILE__) + '/../../lib/tumblfetch/templates/.tumblfetch'
    FileUtils.cp(path, '.')
    Tumblr::Client.any_instance.stub(:posts).and_return { {'posts' => []} }
  end

  it { expect(subject.analyze).to be_a Hash }
  it { expect(subject.analyze).to include :photos }
  it { expect(subject.analyze).to include :posts }

  context 'when No post' do
    it 'should return :posts == 0' do
      expect(subject.analyze[:posts]).to eq 0
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
      expect(subject.analyze[:posts]).to eq 2
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
      expect(subject.analyze[:posts]).to eq 1
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
      expect(subject.analyze[:posts]).to eq 3
    end
  end

  context 'NON photoset' do
    it 'should return correct :photos' do
      subject.config = {'last_fetch_id' => :the_last}
      Tumblr::Client.any_instance.stub(:posts).and_return do
        {'posts' => [
          {'id' => 987, 'photos' => ['photo1']},
          {'id' => :the_last}]
        }
      end
      expect(subject.analyze[:photos]).to eq 1
    end
  end

  context '1 photoset' do
    it 'should return correct :photos' do
      subject.config = {'last_fetch_id' => :the_last}
      Tumblr::Client.any_instance.stub(:posts).and_return do
        {'posts' => [
          {'id' => 987, 'photos' => ['photo1', 'photo2']},
          {'id' => :the_last}]
        }
      end
      expect(subject.analyze[:photos]).to eq 2
    end
  end

  after do
    FileUtils.remove('.tumblfetch')
  end
end
