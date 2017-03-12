module Barrymore
  # Barrymore implementation of message.
  # You could use it or provide yours with the same behavior
  class Message
    attr_reader :chat, :text, :data

    def initialize(chat:, text:, data: nil)
      self.chat = chat.freeze
      self.text = text.freeze
      self.data = data.freeze if data
    end

    private

    attr_writer :chat, :text, :data
  end
end
