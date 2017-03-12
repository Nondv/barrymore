require 'barrymore/version'
require 'barrymore/message'

module Barrymore
  class UndefinedCommandError < StandardError; end
  class NoCommandInProgressError < StandardError; end

  # It is used for storing commands. You don't need it
  class BotCommand
    attr_reader :name, :execution
    attr_accessor :continuation

    def initialize(name, &block)
      raise(ArgumentError, 'no block given') unless block
      @name = name.freeze
      @execution = block
    end
  end

  def self.included(klass)
    klass.include InstanceMethods
    klass.extend ClassMethods
  end

  module InstanceMethods
    # command should be specified in msg.text.
    # chat should be specified in msg.chat.
    def execute_command(msg)
      raise(UndefinedCommandError, msg.text) unless command_defined?(msg)
      instance_exec(msg, &get_barrymore_command(msg).execution)
    end

    def start_command_processing(msg)
      commands_in_progress[msg.chat] = msg.text
    end

    def stop_command_processing(msg)
      commands_in_progress.delete(msg.chat)
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

    private

    def barrymore_commands
      self.class.send :barrymore_commands
    end

    def get_barrymore_command(*args)
      self.class.send(:get_barrymore_command, *args)
    end
  end

  module ClassMethods
    def define_command(name, &block)
      raise(ArgumentError, 'no block given') unless block
      barrymore_commands[name] = BotCommand.new(name, &block)
    end

    def define_command_continuation(name, &block)
      raise(ArgumentError, 'no block given') unless block
      raise(UndefinedCommandError, name) unless command_defined?(name)
      get_barrymore_command(name).continuation = block
    end

    # arg [Message|String]
    def command_defined?(arg)
      name = arg.is_a?(String) ? arg : arg.text
      barrymore_commands.key?(name)
    end

    private

    # arg [Message|String]
    def get_barrymore_command(arg)
      name = arg.is_a?(String) ? arg : arg.text
      barrymore_commands[name]
    end

    def barrymore_commands
      @barrymore_commands ||= {}
    end
  end
end
