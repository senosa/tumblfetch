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
    path = File.dirname(__FILE__) + '/../../../lib/tumblfetch/templates/.tumblfetch'
    Pathname.new(path).realpath.to_s
  }

  before do
    File.stub(:exist?).and_return(false)
    File.stub(:exist?).with(templatefile).and_return(true)
    File.stub(:exist?).with(dottumblr).and_return(dot_tumblr_exist)
    File.stub(:exist?).with('.tumblfetch').and_return(dot_tumblfetch_exist)
  end

  context 'when ~/.tumblr is NON-existent' do
    let(:dot_tumblr_exist) { false }
    let(:dot_tumblfetch_exist) { false }

    before do
      @msg =  "`~/.tumblr` can't be found. Run `tumblr` for generating it.\n"
      @msg << "For details, see https://github.com/tumblr/tumblr_client#the-irb-console"
    end

    it { should include @msg }

    it 'should NOT generate a .tumblfetch' do
      subject
      expect(FileTest.exist?('.tumblfetch')).to be_false
    end
  end

  context 'when ~/.tumblr exist' do
    let(:dot_tumblr_exist) { true }
    
    context 'when .tumblfetch is NON-existent' do
      let(:dot_tumblfetch_exist) { false }

      before { @msg = "create  .tumblfetch" }

      it { should include @msg }
    
      it 'should generate a .tumblfetch' do
        subject
        expect(FileTest.exist?('.tumblfetch')).to be_true
      end
    end

    context 'when .tumblfetch already exist' do
      let(:dot_tumblfetch_exist) { true }

      before { @msg = "`.tumblfetch` already exists in this directory." }
    
      it { should include @msg }

      it 'should NOT generate a .tumblfetch' do
        subject
        expect(FileTest.exist?('.tumblfetch')).to be_false
      end
    end
  end
end
