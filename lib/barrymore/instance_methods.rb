module Barrymore
  #
  # Instance-level helpers
  #
  module InstanceMethods
    # command should be specified in msg.text.
    # chat should be specified in msg.chat.
    def execute_command(msg)
      raise(UndefinedCommandError, msg.text) unless command_defined?(msg)
      instance_exec(msg, &get_barrymore_command(msg).execution)
    end

    def start_command_processing(msg)
      # TODO: use chat_data ?
      commands_in_progress[msg.chat] = msg.text
    end

    def stop_command_processing(msg)
      commands_in_progress.delete(msg.chat)
    end

    # arg [Object] - arg.chat or arg itself will be used
    def set_chat_data(arg, data)
      chat = arg.respond_to?(:chat) ? arg.chat : arg
      barrymore_chats_data[chat] = chat_data(arg).merge(data).freeze
    end

    # arg [Object] - arg.chat or arg itself will be used
    def chat_data(arg)
      chat = arg.respond_to?(:chat) ? arg.chat : arg
      barrymore_chats_data[chat] ||= {}.freeze
    end

    def continue_command(msg)
      raise(NoCommandInProgressError, msg.chat.to_s) unless command_in_progress?(msg)
      proc = get_barrymore_command(commands_in_progress[msg.chat]).continuation
      instance_exec(msg, &proc)
    end

    def command_defined?(*args)
      self.class.command_defined?(*args)
    end

    def command_in_progress?(msg)
      commands_in_progress.key?(msg.chat)
    end

    def commands_in_progress
      @commands_in_progress ||= {}
    end

    #
    # You don't need private methods.
    # They are only for barrymore implementation
    #

    private

    def barrymore_chats_data
      @barrymore_chats_data ||= {}
    end

    def barrymore_commands
      self.class.send :barrymore_commands
    end

    def get_barrymore_command(*args)
      self.class.send(:get_barrymore_command, *args)
    end
  end
end
