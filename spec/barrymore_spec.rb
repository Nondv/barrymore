require 'spec_helper'

describe Barrymore do
  class TestBot
    include Barrymore

    def process_message(chat, text)
      message = Message.new(text: text, chat: chat)

      if command_defined?(message)
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
end
