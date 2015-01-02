require 'spec_helper'
require 'tumblfetch/photo'

describe Tumblfetch::Photo do
  let(:photo) do Tumblfetch::Photo.new(
    post_id: post_id,
    link_url: link_url,
    photoset_idx: photoset_idx,
    original_url: original_url,
    original_width: original_width,
    alt_1_url: alt_1_url
    )
  end
  let(:post_id) { 1 }
  let(:link_url) { nil }
  let(:photoset_idx) { nil }
  let(:original_url) { 'The_original_url' }
  let(:original_width) { 500 }
  let(:alt_1_url) { 'The_alt_1_url' }

  describe '#target_url' do
    subject { photo.target_url }

    context 'when original_url is valid' do
      let(:original_url) { 'http://www.snest.net/tumblfetch/under500.jpg' }

      it { should include original_url }
    end

    context 'when link_url is valid' do
      let(:link_url) { 'http://www.snest.net/tumblfetch/under500.jpg' }

      it { should include link_url }
    end

    context 'when all targets are invalid' do
      it { should include original_url }
    end
  end

  describe '#filename' do
    subject { photo.filename }

    context 'when original_url is valid' do
      let(:original_url) { 'http://www.snest.net/tumblfetch/under500.jpg' }

      it { should include '1.jpeg' }

      context 'with photoset_idx' do
        let(:photoset_idx) { 3 }

        it { should include '1_3.jpeg' }
      end
    end
  end
end
