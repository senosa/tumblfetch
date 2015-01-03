require 'spec_helper'
require 'tumblfetch/cli'
require 'pathname'

describe Tumblfetch::CLI, '#version' do
  subject { capture(:stdout) { Tumblfetch::CLI.new.version } }
  it { is_expected.to include Tumblfetch::VERSION }
end

describe Tumblfetch::CLI, '#init' do
  subject { capture(:stdout) { Tumblfetch::CLI.new.init } }
  let(:dottumblr) { File.join(ENV['HOME'], '.tumblr') }
  let(:templatefile) {
    path = File.dirname(__FILE__) + '/../../../lib/tumblfetch/templates/.fetch'
    Pathname.new(path).realpath.to_s
  }

  before do
    allow(File).to receive(:exist?).and_return(false)
    allow(File).to receive(:exist?).with(templatefile).and_return(true)
    allow(File).to receive(:exist?).with(dottumblr).and_return(dot_tumblr_exist)
    allow(File).to receive(:exist?).with('.fetch').and_return(dot_fetch_exist)
  end

  context 'when ~/.tumblr is NON-existent' do
    let(:dot_tumblr_exist) { false }
    let(:dot_fetch_exist) { false }

    it { is_expected.to include "create  .fetch" }

    it 'should generate a .fetch' do
      subject
      expect(FileTest.exist?('.fetch')).to be_truthy
    end

    it 'should NOT contain credentials' do
      subject
      config = YAML.load_file('.fetch')
      expect(config['consumer_key']).to be_nil
    end
  end

  context 'when ~/.tumblr exist' do
    let(:dot_tumblr_exist) { true }
    let(:dot_fetch_exist) { false }
    before do
      allow(YAML).to receive(:load_file).with(File.join(ENV['HOME'], '.tumblr'))
        .and_return({'consumer_key' => 'TheKey'})
      allow(YAML).to receive(:load_file).with('.fetch')
        .and_return({'blog_name' => 'abc'})
    end

    it { is_expected.to include "create  .fetch" }

    it 'should contain credentials' do
      subject
      config = open('.fetch').read
      expect(config).to include "consumer_key: TheKey\n"
    end

    it 'should NOT change template value' do
      subject
      config = open('.fetch').read
      expect(config).to include "blog_name: abc\n"
    end
  end

  context 'when .fetch already exist' do
    let(:dot_tumblr_exist) { true }
    let(:dot_fetch_exist) { true }

    it { is_expected.to include "`.fetch` already exists in this directory." }

    it 'should NOT generate a .fetch' do
      subject
      expect(FileTest.exist?('.fetch')).to be_falsey
    end
  end
end

describe Tumblfetch::CLI, '#fetch' do
  subject { capture(:stdout) { Tumblfetch::CLI.new.fetch } }

  context 'when .fetch is NON-existent' do
    it { is_expected.to include "`.fetch` can't be found." }
  end

  context 'when .fetch exist' do
    before do
      path = File.dirname(__FILE__) + '/../../../lib/tumblfetch/templates/.fetch'
      FileUtils.cp(path, '.')
      config = YAML.load_file('.fetch')
      config['consumer_key'] = 'consumer'
      config['consumer_secret'] = 'secret'
      config['oauth_token'] = 'oauth'
      config['oauth_token_secret'] = 'oauth_secret'
      open('.fetch', 'w') {|file| file.write(config.to_yaml) }
      allow_any_instance_of(Tumblfetch::Fetcher).to receive(:analyze).and_return({posts: 0})
      @start_msg = 'Start fetching.'
    end

    %w[consumer_key consumer_secret oauth_token oauth_token_secret].each do |credential_name|
      context "but .fetch NOT contain #{credential_name}" do
        before do
          config = YAML.load_file('.fetch')
          config["#{credential_name}"] = nil
          open('.fetch', 'w') {|file| file.write(config.to_yaml) }
        end

        it { is_expected.to include "`.fetch` doesn't contain credentials." }
        it { is_expected.not_to include @start_msg }
      end
    end

    context 'when posts == 0' do
      it { is_expected.to include @start_msg }
      it { is_expected.to include 'No new post.' }
    end

    context 'when posts == 99 and fails NOT exist' do
      before do
        allow_any_instance_of(Tumblfetch::Fetcher).to receive(:analyze).and_return({posts: 99, photos: 12})
        allow_any_instance_of(Tumblfetch::Fetcher).to receive(:download).and_return({success: 9, fails: []})
        @found_msg = '12 photos (in 99 posts) are found.'
        @success_msg = '9 photos are downloaded'
        @fail_msg = "photos can't download"
      end

      it { is_expected.to include @start_msg }
      it { is_expected.to include @found_msg }
      it { is_expected.to include @success_msg }
      it { is_expected.not_to include @fail_msg }
    end

    context 'when fails exist' do
      before do
        allow_any_instance_of(Tumblfetch::Fetcher).to receive(:analyze).and_return({posts: 3, photos: 6})
        allow_any_instance_of(Tumblfetch::Fetcher).to receive(:download)
          .and_return({success: 5, fails: ['FailDetail']})
        @fail_msg = "1 photos can't download"
        @fail_detail = 'FailDetail'
      end

      it { is_expected.to include @start_msg }
      it { is_expected.to include @fail_msg }
      it { is_expected.to include @fail_detail }
    end

    after do
      FileUtils.remove('.fetch')
    end
  end
end
