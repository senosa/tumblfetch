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
        .and_return { {'posts' => [{'id' => 123}, {'id' => 456}]} }
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 20})
        .and_return { {'posts' => []} }
      expect(subject.analyze[:posts]).to eq 2
    end
  end

  context 'when 1 New post in 3 posts' do
    it 'should return :posts == 1' do
      subject.config = {'last_fetch_id' => 654}
      Tumblr::Client.any_instance.stub(:posts)
        .and_return { {'posts' => [{'id' => 987}, {'id' => 654}, {'id' => 321}]} }
      expect(subject.analyze[:posts]).to eq 1
    end
  end

  context 'when last fetch post is in second response' do
    it 'should return :posts == 5' do
      subject.config = {'blog_name' => 'tt','last_fetch_id' => 555}
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 0})
        .and_return { {'posts' => [{'id' => 999}, {'id' => 888}, {'id' => 777}]} }
      Tumblr::Client.any_instance.stub(:posts)
        .with('tt', {:type => 'photo', :offset => 20})
        .and_return { {'posts' => [{'id' => 666}, {'id' => 555}, {'id' => 444}]} }
      expect(subject.analyze[:posts]).to eq 4
    end
  end

  after do
    FileUtils.remove('.tumblfetch')
  end
end
