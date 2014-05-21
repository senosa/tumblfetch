require 'spec_helper'
require 'tumblfetch/cli'

describe CLI do
  describe '#version' do
    subject { capture(:stdout) { CLI.new.invoke('version') }.strip }
    it { should be_eql Tumblfetch::VERSION }
  end

  describe '#init' do
    context 'when .tumblfetch is nonexistent' do
      it 'should generate a .tumblfetch' do
        capture(:stdout) { CLI.new.invoke('init') }
        File.exist?('./.tumblfetch').should be_true
      end

      it 'should print success message' do
        msg = capture(:stdout) { CLI.new.invoke('init') }
        expect(msg).to include CLI::SETTINGS_GENERATED_MSG
      end
    end

    context 'when .tumblfetch already exist' do
      it 'should print warning message' do
        File.open('./.tumblfetch', 'w').close
        msg = capture(:stderr) { CLI.new.invoke('init') }
        expect(msg).to include CLI::SETTINGS_EXIST_MSG
      end
    end
  end
end
