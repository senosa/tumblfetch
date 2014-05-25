require 'spec_helper'
require 'tumblfetch/cli'

describe Tumblfetch::CLI, '#version' do
  it 'should print correct version' do
    output = capture(:stdout) { subject.version }
    expect(output).to include Tumblfetch::VERSION
  end
end

describe Tumblfetch::CLI, '#init' do
  context 'when ~/.tumblr is nonexistent' do
    it 'should print execute `tumblr`' do
      File.stub(:exist?).and_return(false)
      output = capture(:stdout) { subject.init }
      expect(output).to include Tumblfetch::CLI::EXECUTE_TUMBLR_MSG
    end
  end

  context 'when ~/.tumblr exist' do
    context 'when .tumblfetch is nonexistent' do
      it 'should generate a .tumblfetch' do
        output = capture(:stdout) { subject.init }
        File.exist?('./.tumblfetch').should be_true
      end

      it 'should print success message' do
        output = capture(:stdout) { subject.init }
        expect(output).to include Tumblfetch::CLI::SETTINGS_GENERATED_MSG
      end
    end

    context 'when .tumblfetch already exist' do
      it 'should print warning message' do
        File.open('./.tumblfetch', 'w').close
        output = capture(:stdout) { subject.init }
        expect(output).to include Tumblfetch::CLI::SETTINGS_EXIST_MSG
      end
    end
  end
end
