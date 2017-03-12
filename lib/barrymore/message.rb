module Barrymore
  # Barrymore implementation of message.
  # You could use it or provide yours with the same behavior
  class Message
    attr_reader :chat, :text, :data

    def initialize(chat:, text:, data: nil)
      self.chat = chat.clone.freeze
      self.text = text.clone.freeze
      self.data = data.clone.freeze if data
    end

    private

    attr_writer :chat, :text, :data
  end
end
