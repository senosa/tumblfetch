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

  context 'when ~/.tumblr is nonexistent' do
    it 'should print execute `tumblr`' do
      File.stub(:exist?).and_return(false)
      msg =  "`~/.tumblr` can't be found. Run `tumblr` for generating it.\n"
      msg << "For details, see https://github.com/tumblr/tumblr_client#the-irb-console"
      expect(output).to include msg
    end
  end

  context 'when ~/.tumblr exist' do
    context 'when .tumblfetch is nonexistent' do
      it 'should generate a .tumblfetch' do
        output
        File.exist?('.tumblfetch').should be_true
      end

      it 'should print success message' do
        msg = "`.tumblfetch` has been placed in this directory."
        expect(output).to include msg
      end
    end

    context 'when .tumblfetch already exist' do
      it 'should print warning message' do
        File.stub(:exist?).and_return(true)
        msg = "`.tumblfetch` already exists in this directory."
        expect(output).to include msg
      end
    end
  end
end
