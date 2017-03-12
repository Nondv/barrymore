require 'spec_helper'

describe Barrymore do
  class TestBot
    include Barrymore

    def process_message(chat, text)
      message = Message.new(text: text, chat: chat)

      if command_in_progress?(message)
        continue_command(message)
      elsif command_defined?(message)
        execute_command(message)
      else
        send_message chat_id: chat,
                     text: 'missing'
      end
    end

    def sent
      @sent ||= []
    end

    def send_message(msg)
      sent << msg
    end
  end

  subject { TestBot.new }

  context 'with plain one-step command' do
    before do
      TestBot.define_command('/start') do |msg|
        send_message(chat_id: msg.chat, text: 'bugaga')
      end
    end

    it 'works' do
      subject.process_message(1, '/start')
      expect(subject.sent).to include(chat_id: 1, text: 'bugaga')
    end
  end

  context 'with multiple-steps command' do
    before do
      TestBot.define_command('/google') do |msg|
        start_command_processing(msg)
        send_message(chat_id: msg.chat, text: 'What do you want me to google?')
      end

      TestBot.define_command_continuation('/google') do |msg|
        stop_command_processing(msg)
        send_message(chat_id: msg.chat, text: "http://lmgtfy.com/?q=#{msg.text}")
      end
    end

    it 'works' do
      subject.process_message(1, '/google')
      expect(subject.sent).to include(chat_id: 1, text: 'What do you want me to google?')
      subject.process_message(1, 'hello')
      expect(subject.sent).to include(chat_id: 1, text: 'http://lmgtfy.com/?q=hello')
    end

    context 'with different chats' do
      before do
        subject.process_message(1, '/google')
        subject.process_message(2, 'hello')
        subject.process_message(1, 'hello')
      end

      it 'doesnt mess them up' do
        expect(subject.sent[0]).to eq(chat_id: 1, text: 'What do you want me to google?')
        expect(subject.sent[1]).to eq(chat_id: 2, text: 'missing')
        expect(subject.sent[2]).to eq(chat_id: 1, text: 'http://lmgtfy.com/?q=hello')
      end
    end
  end

  describe 'chat data' do
    before do
      TestBot.define_command('/start') do |msg|
        set_chat_data(msg, Time.now => 'hey')
        send_message(chat_id: msg.chat, text: 'bugaga')
      end
    end

    it 'works' do
      subject.process_message(1, '/start')
      expect(subject.sent[0]).to eq(chat_id: 1, text: 'bugaga')
      expect(subject.chat_data(1).values).to eq %w(hey)
      expect(subject.chat_data(1).keys[0]).to be_a Time
    end

    it 'merges multiple sets' do
      subject.process_message(1, '/start')
      subject.process_message(1, '/start')
      expect(subject.chat_data(1).values).to eq %w(hey hey)
      expect(subject.chat_data(1).keys.all? { |k| k.is_a? Time }).to be true
    end
  end
end
