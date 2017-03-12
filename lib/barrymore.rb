require 'barrymore/version'
require 'barrymore/message'

module Barrymore
  class UndefinedCommandError < StandardError; end

  def self.included(klass)
    klass.include InstanceMethods
    klass.extend ClassMethods
  end

  module InstanceMethods
    # command should be specified in msg.text.
    # chat should be specified in msg.chat.
    def execute_command(msg)
      raise(UndefinedCommandError, msg.text) unless command_defined?(msg)
      instance_exec(msg, &get_barrymore_command(msg))
    end

    def command_defined?(*args)
      self.class.command_defined?(*args)
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
      barrymore_commands[name] = block
    end

    def command_defined?(msg)
      barrymore_commands.key?(msg.text)
    end

    private

    def get_barrymore_command(msg)
      barrymore_commands[msg.text]
    end

    def barrymore_commands
      @barrymore_commands ||= {}
    end
  end
end
