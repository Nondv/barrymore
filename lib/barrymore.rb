require 'barrymore/version'
require 'barrymore/message'
require 'barrymore/class_methods'
require 'barrymore/instance_methods'

#
# Barrymore is a DSL for defining chat bots commands.
# Especially useful for Telegram bots.
#
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
end
