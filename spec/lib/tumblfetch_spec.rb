require 'spec_helper'
require 'tumblfetch'

describe Tumblfetch::Fetcher, '#analyze' do
  subject { @fetcher.analyze }
  before do
    @empty_array = []
    allow_any_instance_of(Tumblr::Client).to receive(:posts).and_return({'posts' => @empty_array})
    config = {'blog_name' => 'tt', 'last_fetch_id' => nil}
    @fetcher = Tumblfetch::Fetcher.new(config)
  end

  it { is_expected.to be_a Hash }
  it { is_expected.to have_key :photos }
  it { is_expected.to have_key :posts }

  describe '[:posts]' do
    subject { @fetcher.analyze[:posts] }

    it { is_expected.to be_a Integer }

    context 'when 2 posts and first fetch' do
      before do
        allow_any_instance_of(Tumblr::Client).to receive(:posts)
          .with('tt', {:type => 'photo', :offset => 0})
          .and_return(
            {'posts' => [
              {'id' => 123, 'photos' => @empty_array},
              {'id' => 456, 'photos' => @empty_array}
              ]
            }
          )
        allow_any_instance_of(Tumblr::Client).to receive(:posts)
          .with('tt', {:type => 'photo', :offset => 20})
          .and_return({'posts' => @empty_array})
      end
      it { is_expected.to eq 2 }
    end

    context 'when 1 New post in 3 posts' do
      before do
        @fetcher.config['last_fetch_id'] = :the_last
        allow_any_instance_of(Tumblr::Client).to receive(:posts)
          .and_return(
            {'posts' => [
              {'id' => 987, 'photos' => @empty_array},
              {'id' => :the_last},
              {'id' => 321}
              ]
            }
          )
      end
      it { is_expected.to eq 1 }
    end

    context 'when last fetch post is in second response' do
      before do
        @fetcher.config['last_fetch_id'] = :the_last
        allow_any_instance_of(Tumblr::Client).to receive(:posts)
          .with('tt', {:type => 'photo', :offset => 0})
          .and_return(
            {'posts' => [
              {'id' => 99, 'photos' => @empty_array}
              ]
            }
          )
        allow_any_instance_of(Tumblr::Client).to receive(:posts)
          .with('tt', {:type => 'photo', :offset => 20})
          .and_return(
            {'posts' => [
              {'id' => 88, 'photos' => @empty_array},
              {'id' => 77, 'photos' => @empty_array},
              {'id' => :the_last}
              ]
            }
          )
      end
      it { is_expected.to eq 3 }
    end
  end

  describe '[:photos]' do
    subject { @fetcher.analyze[:photos] }
    before do
      allow(Tumblfetch::Photo).to receive(:new) { double 'photo' }
      @fetcher.config['last_fetch_id'] = :the_last
    end

    it { is_expected.to be_a Integer }
  end

end

describe Tumblfetch::Fetcher, '#download' do
  subject { @fetcher.download }
  before do
    @fetcher = Tumblfetch::Fetcher.new('conf')
    @photo = double 'photo'
    allow(@photo).to receive(:download).and_return ['success']
    allow(@photo).to receive(:post_id).and_return 123
    @fetcher.photos = [@photo]
  end

  it { is_expected.to be_a Hash }
  it { is_expected.to have_key :success }
  it { is_expected.to have_key :fails }

  describe '[:success]' do
    subject { @fetcher.download[:success] }

    it { is_expected.to be_a Integer }

    context 'when 2 photos all success' do
      before { @fetcher.photos << @photo }
      it { is_expected.to eq 2 }
    end

    context 'when Photo#download return fail' do
      before { allow(@photo).to receive(:download).and_return 'fail' }
      it { is_expected.to eq 0 }
    end
  end

  describe '[:fails]' do
    subject { @fetcher.download[:fails] }

    it { is_expected.to be_a Array }

    context 'when 2 photos all success' do
      before { @fetcher.photos << @photo }
      it { is_expected.to be_empty }
    end

    context 'when Photo#download return fail' do
      before { allow(@photo).to receive(:download).and_return 'fail' }
      it { is_expected.to eq ['fail'] }
    end
  end

end
