require 'spec_helper'
require 'tumblfetch/cli'

describe Tumblfetch::CLI do
  describe '#version' do
    subject { capture(:stdout) { Tumblfetch::CLI.new.invoke('version') }.strip }
    it { should be_eql Tumblfetch::VERSION }
  end

  describe '#init' do
    context 'when ~/.tumblr is nonexistent' do
      it 'should print execute `tumblr`' do
        File.stub(:exist?).and_return(false)
        msg = capture(:stderr) { Tumblfetch::CLI.new.invoke('init') }
        expect(msg).to include Tumblfetch::CLI::EXECUTE_TUMBLR_MSG
      end
    end

    context 'when .tumblfetch is nonexistent' do
      it 'should generate a .tumblfetch' do
        capture(:stdout) { Tumblfetch::CLI.new.invoke('init') }
        File.exist?('./.tumblfetch').should be_true
      end

      it 'should print success message' do
        msg = capture(:stdout) { Tumblfetch::CLI.new.invoke('init') }
        expect(msg).to include Tumblfetch::CLI::SETTINGS_GENERATED_MSG
      end
    end

    context 'when .tumblfetch already exist' do
      it 'should print warning message' do
        File.open('./.tumblfetch', 'w').close
        msg = capture(:stderr) { Tumblfetch::CLI.new.invoke('init') }
        expect(msg).to include Tumblfetch::CLI::SETTINGS_EXIST_MSG
      end
    end
  end
end
