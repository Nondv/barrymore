require 'spec_helper'

describe Barrymore::Message do
  describe 'instance methods' do
    subject { described_class.instance_methods }

    %i(chat text data).each do |method|
      it { is_expected.to include(method) }
    end
  end

  let(:text) { 'some text bla bla bla' }
  let(:chat) { 'chat unique identificator' }
  let(:data) { { a: '1234', b: '5678' } }

  subject { described_class.new(text: text, chat: chat, data: data) }

  %i(text chat data).each do |attr|
    it "correctly returns #{attr}" do
      expect(subject.send(attr)).to eq send(attr)
    end
  end
end
