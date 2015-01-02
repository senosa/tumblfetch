require 'spec_helper'
require 'tumblfetch'

describe Tumblfetch::Fetcher, '#analyze' do
  subject { @fetcher.analyze }
  before do
    @empty_array = []
    Tumblr::Client.any_instance.stub(:posts).and_return { {'posts' => @empty_array} }
    config = {'blog_name' => 'tt', 'last_fetch_id' => nil}
    @fetcher = Tumblfetch::Fetcher.new(config)
  end

  it { should be_a Hash }
  it { should have_key :photos }
  it { should have_key :posts }

  describe '[:posts]' do
    subject { @fetcher.analyze[:posts] }

    it { should be_a Integer }

    context 'when 2 posts and first fetch' do
      before do
        Tumblr::Client.any_instance.stub(:posts)
          .with('tt', {:type => 'photo', :offset => 0})
          .and_return do
            {'posts' => [
              {'id' => 123, 'photos' => @empty_array},
              {'id' => 456, 'photos' => @empty_array}
              ]
            }
          end
        Tumblr::Client.any_instance.stub(:posts)
          .with('tt', {:type => 'photo', :offset => 20})
          .and_return { {'posts' => @empty_array} }
      end
      it { should eq 2 }
    end

    context 'when 1 New post in 3 posts' do
      before do
        @fetcher.config['last_fetch_id'] = :the_last
        Tumblr::Client.any_instance.stub(:posts)
          .and_return do
            {'posts' => [
              {'id' => 987, 'photos' => @empty_array},
              {'id' => :the_last},
              {'id' => 321}
              ]
            }
          end
      end
      it { should eq 1 }
    end

    context 'when last fetch post is in second response' do
      before do
        @fetcher.config['last_fetch_id'] = :the_last
        Tumblr::Client.any_instance.stub(:posts)
          .with('tt', {:type => 'photo', :offset => 0})
          .and_return do
            {'posts' => [
              {'id' => 99, 'photos' => @empty_array}
              ]
            }
          end
        Tumblr::Client.any_instance.stub(:posts)
          .with('tt', {:type => 'photo', :offset => 20})
          .and_return do
            {'posts' => [
              {'id' => 88, 'photos' => @empty_array},
              {'id' => 77, 'photos' => @empty_array},
              {'id' => :the_last}
              ]
            }
          end
      end
      it { should eq 3 }
    end
  end

  describe '[:photos]' do
    subject { @fetcher.analyze[:photos] }
    before do
      Tumblfetch::Photo.stub(:new) { double 'photo' }
      @fetcher.config['last_fetch_id'] = :the_last
    end

    it { should be_a Integer }
  end

end

describe Tumblfetch::Fetcher, '#download' do
  subject { @fetcher.download }
  before do
    @fetcher = Tumblfetch::Fetcher.new('conf')
    @photo = double 'photo'
    @photo.stub(:download).and_return { ['success'] }
    @fetcher.photos = [@photo]
  end

  it { should be_a Hash }
  it { should have_key :success }
  it { should have_key :fails }

  describe '[:success]' do
    subject { @fetcher.download[:success] }

    it { should be_a Integer }

    context 'when 2 photos all success' do
      before { @fetcher.photos << @photo }
      it { should eq 2 }
    end

    context 'when Photo#download return fail' do
      before { @photo.stub(:download).and_return { 'fail' } }
      it { should eq 0 }
    end
  end

  describe '[:fails]' do
    subject { @fetcher.download[:fails] }

    it { should be_a Array }

    context 'when 2 photos all success' do
      before { @fetcher.photos << @photo }
      it { should be_empty }
    end

    context 'when Photo#download return fail' do
      before { @photo.stub(:download).and_return { 'fail' } }
      it { should have(1).fails }
    end
  end

end
