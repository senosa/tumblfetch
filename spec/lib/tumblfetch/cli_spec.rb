require 'spec_helper'
require 'tumblfetch/cli'

describe Tumblfetch::CLI, '#version' do
  it 'should print correct version' do
    output = capture(:stdout) { subject.version }
    expect(output).to include Tumblfetch::VERSION
  end
end

describe Tumblfetch::CLI, '#init' do
  let(:output) { capture(:stdout) { subject.init } }
  let(:dottumblr) { File.join(ENV['HOME'], '.tumblr') }

  before do
    File.stub(:exist?).with(dottumblr).and_return(dot_tumblr_exist)
    File.stub(:exist?).with('.tumblfetch').and_return(dot_tumblfetch_exist)
  end

  context 'when ~/.tumblr is nonexistent' do
    let(:dot_tumblr_exist) { false }
    let(:dot_tumblfetch_exist) { false }

    it 'should print execute `tumblr`' do
      msg =  "`~/.tumblr` can't be found. Run `tumblr` for generating it.\n"
      msg << "For details, see https://github.com/tumblr/tumblr_client#the-irb-console"
      expect(output).to include msg
    end

    it 'should NOT generate a .tumblfetch' do
      output
      FileTest.exist?('.tumblfetch').should be_false
    end
  end

  context 'when ~/.tumblr exist' do
    let(:dot_tumblr_exist) { true }
    
    context 'when .tumblfetch is nonexistent' do
      let(:dot_tumblfetch_exist) { false }
    
      it 'should generate a .tumblfetch' do
        output
        FileTest.exist?('.tumblfetch').should be_true
      end

      it 'should print success message' do
        msg = "`.tumblfetch` has been placed in this directory."
        expect(output).to include msg
      end
    end

    context 'when .tumblfetch already exist' do
      let(:dot_tumblfetch_exist) { true }
    
      it 'should print warning message' do
        msg = "`.tumblfetch` already exists in this directory."
        expect(output).to include msg
      end

      it 'should NOT generate a .tumblfetch' do
        output
        FileTest.exist?('.tumblfetch').should be_false
      end
    end
  end
end
