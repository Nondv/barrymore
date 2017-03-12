# Barrymore

[![Build Status](https://travis-ci.org/Nondv/barrymore.svg?branch=master)](https://travis-ci.org/Nondv/barrymore)

Barrymore is a DSL for defining chat bot commands (like telegram bot commands).
To create telegram bot you will need to use bot api gem (like `telegram-bot-ruby`).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'barrymore'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install barrymore

## Usage

This is an example of usage Barrymore for telegram bot using gem [`telegram-bot-ruby`](https://github.com/atipugin/telegram-bot-ruby).
But Barrymore can be used for whatever chats you want.
For example, [specs](spec/barrymore_spec.rb)  are written without any
chat at all.


```ruby
require 'telegram/bot'
require 'barrymore'

class MyBot < Telegram::Bot::Client
  include Barrymore

  #
  # /start
  #

  define_command('/start') do |msg|
    if chat_data(msg)[:started_at]
      api.send_message(chat_id: msg.chat, text: 'We met already')
    else
      set_chat_data(msg, started_at: Time.now)
      api.send_message(chat_id: msg.chat, text: "Hello, #{msg.data[:name]}!")
    end
  end

  #
  # /google
  #

  define_command('/google') do |msg|
    start_command_processing(msg)
    api.send_message(chat_id: msg.chat, text: 'What do you want to google?')
  end

  define_command_continuation('/google') do |msg|
    stop_command_processing(msg)
    api.send_message(chat_id: msg.chat, text: "http://lmgtfy.com/?q=#{URI.escape msg.text}")
  end

  # msg [Barrymore::Message]
  def process_message(msg)
    if command_in_progress?(msg)
      continue_command(msg)
    elsif command_defined?(msg)
      execute_command(msg)
    else
      api.send_message(chat_id: msg.chat, text: 'wrong command!')
    end
  end

  # converts telegram message to barrymore message
  def berrymore_message(telegram_message)
    Message.new text: telegram_message.text,
                chat: telegram_message.chat.id,
                data: { name: telegram_message.from.first_name }
  end
end

token = raise 'REPLACE IT WITH YOUR TOKEN'

MyBot.run(token) do |bot|
  bot.listen do |telegram_message|
    barrymore_msg = bot.berrymore_message(telegram_message)
    bot.process_message(barrymore_msg)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Nondv/barrymore.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

