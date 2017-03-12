module Barrymore
  #
  # Class-level DSL
  #
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

    #
    # You don't need private methods.
    # They are only for barrymore implementation
    #

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
