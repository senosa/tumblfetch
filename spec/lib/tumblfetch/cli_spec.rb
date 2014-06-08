require 'spec_helper'
require 'tumblfetch/cli'
require 'pathname'

describe Tumblfetch::CLI, '#version' do
  subject { capture(:stdout) { Tumblfetch::CLI.new.version } }
  it { should include Tumblfetch::VERSION }
end

describe Tumblfetch::CLI, '#init' do
  subject { capture(:stdout) { Tumblfetch::CLI.new.init } }
  let(:dottumblr) { File.join(ENV['HOME'], '.tumblr') }
  let(:templatefile) {
    path = File.dirname(__FILE__) + '/../../../lib/tumblfetch/templates/.fetch'
    Pathname.new(path).realpath.to_s
  }

  before do
    File.stub(:exist?).and_return(false)
    File.stub(:exist?).with(templatefile).and_return(true)
    File.stub(:exist?).with(dottumblr).and_return(dot_tumblr_exist)
    File.stub(:exist?).with('.fetch').and_return(dot_fetch_exist)
  end

  context 'when ~/.tumblr is NON-existent' do
    let(:dot_tumblr_exist) { false }
    let(:dot_fetch_exist) { false }

    before do
      @msg =  "`~/.tumblr` can't be found."
    end

    it { should include @msg }

    it 'should NOT generate a .fetch' do
      subject
      expect(FileTest.exist?('.fetch')).to be_false
    end
  end

  context 'when ~/.tumblr exist' do
    let(:dot_tumblr_exist) { true }

    context 'when .fetch is NON-existent' do
      let(:dot_fetch_exist) { false }

      before { @msg = "create  .fetch" }

      it { should include @msg }

      it 'should generate a .fetch' do
        subject
        expect(FileTest.exist?('.fetch')).to be_true
      end
    end

    context 'when .fetch already exist' do
      let(:dot_fetch_exist) { true }

      before { @msg = "`.fetch` already exists in this directory." }

      it { should include @msg }

      it 'should NOT generate a .fetch' do
        subject
        expect(FileTest.exist?('.fetch')).to be_false
      end
    end
  end
end

describe Tumblfetch::CLI, '#fetch' do
  subject { capture(:stdout) { Tumblfetch::CLI.new.fetch } }
  let(:dottumblr) { File.join(ENV['HOME'], '.tumblr') }

  context 'when ~/.tumblr is NON-existent' do
    before do
      File.stub(:exist?).with(dottumblr).and_return(false)
      @msg = "`~/.tumblr` can't be found."
    end

    it { should include @msg }
  end

  context 'when .fetch is NON-existent' do
    before do
      File.stub(:exist?).with(dottumblr).and_return(true)
      File.stub(:exist?).with('.fetch').and_return(false)
      @msg = "`.fetch` can't be found."
    end

    it { should include @msg }
  end

  context 'when both settings file exist' do
    before do
      path = File.dirname(__FILE__) + '/../../../lib/tumblfetch/templates/.fetch'
      FileUtils.cp(path, '.')
      File.stub(:exist?).with(dottumblr).and_return(true)
      File.stub(:exist?).with('.fetch').and_return(true)
      Tumblfetch::Fetcher.any_instance.stub(:analyze).and_return({posts: 0})
      @msg = "Start fetching."
    end

    it { should include @msg }

    context 'when posts == 0' do
      before do
        Tumblfetch::Fetcher.any_instance.stub(:analyze).and_return({posts: 0})
        @msg = 'No new post.'
      end

      it { should include @msg }
    end

    context 'when posts == 99' do
      before do
        Tumblfetch::Fetcher.any_instance.stub(:analyze).and_return({posts: 99, photos: 12})
        Tumblfetch::Fetcher.any_instance.stub(:download).and_return({success: 9, fails: []})
        @msg = '12 photos (in 99 posts) are found.'
        @successmsg = '9 photos are downloaded'
        @failmsg = "photos can't download"
      end

      it { should include @msg }
      it { should include @successmsg }
      it { should_not include @failmsg }
    end

    context 'when fails exist' do
      before do
        Tumblfetch::Fetcher.any_instance.stub(:analyze).and_return({posts: 99, photos: 123})
        Tumblfetch::Fetcher.any_instance.stub(:download).and_return({success: 12, fails: ['FailMSG']})
        @failmsg = "1 photos can't download"
      end

      it { should include @failmsg }
    end

    after do
      FileUtils.remove('.fetch')
    end
  end
end
