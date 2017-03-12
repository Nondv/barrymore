require 'open-uri'

class MyBot
  include SomeApi
  include Barrymore

  # or whatever callback is used by api gem
  def process_message(data)
    message = Message.new text: data[:text],
                          chat: data[:chat_id],
                          data: { name: data[:username] }

    if command_in_progress?(message)
      continue_command(message)
    elsif command_defined?(message)
      execute_command(message)
    else
      # or whatever method is defined in SomeApi
      api_send chat_id: data[:chat_id],
               message: 'Wrong command!'
    end
  end

  private

  def message_from_data(data)
    Message.new text: data[:text],
                chat: data[:chat_id],
                data: { name: data[:username] }
  end
end

MyBot.define_command('/start') do |msg|
  if chat_data(msg)[:started_at]
    api_send(chat_id: msg.chat, message: 'We met already')
  else
    set_chat_data(msg, started_at: Time.now)
    api_send(chat_id: msg.chat, message: "Hello, #{msg.data[:name]}!")
  end
end

MyBot.define_command('/google') do |msg|
  start_command_processing(msg)
  api_send(chat_id: msg.chat, message: 'What do you want to google?')
end

MyBot.define_command_continuation('/google') do |msg|
  stop_command_processing(msg)
  send_send(chat_id: msg.chat, message: "http://lmgtfy.com/?q=#{URI.escape msg.text}")
end

# or whatever
MyBot.new.run
