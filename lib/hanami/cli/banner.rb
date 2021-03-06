require "hanami/cli/program_name"

module Hanami
  class CLI
    # Command banner
    #
    # @since 0.1.0
    # @api private
    module Banner
      # Prints command banner
      #
      # @param command [Hanami::CLI::Command] the command
      # @param out [IO] standard output
      #
      # @since 0.1.0
      # @api private
      def self.call(command, out)
        output = [
          command_name(command),
          command_name_and_arguments(command),
          command_description(command),
          command_arguments(command),
          command_options(command),
          command_examples(command)
        ].compact.join("\n")

        out.puts output
      end

      # @since 0.1.0
      # @api private
      def self.command_name(command)
        "Command:\n  #{full_command_name(command)}"
      end

      # @since 0.1.0
      # @api private
      def self.command_name_and_arguments(command)
        "\nUsage:\n  #{full_command_name(command)}#{arguments(command)}"
      end

      # @since 0.1.0
      # @api private
      def self.command_examples(command)
        return if command.examples.empty?

        "\nExamples:\n#{command.examples.map { |example| "  #{full_command_name(command)} #{example}" }.join("\n")}"
      end

      # @since 0.1.0
      # @api private
      def self.command_description(command)
        return if command.description.nil?

        "\nDescription:\n  #{command.description}"
      end

      # @since 0.1.0
      # @api private
      def self.command_arguments(command)
        return if command.arguments.empty?
        "\nArguments:\n#{extended_command_arguments(command)}"
      end

      # @since 0.1.0
      # @api private
      def self.command_options(command)
        "\nOptions:\n#{extended_command_options(command)}"
      end

      # @since 0.1.0
      # @api private
      def self.full_command_name(command)
        ProgramName.call(command.command_name)
      end

      # @since 0.1.0
      # @api private
      def self.arguments(command)
        required_arguments = command.required_arguments
        optional_arguments = command.optional_arguments

        required = required_arguments.map { |arg| arg.name.upcase }.join(' ') if required_arguments.any?
        optional = optional_arguments.map { |arg| "[#{arg.name.upcase}]" }.join(' ') if optional_arguments.any?
        result = [required, optional].compact

        " #{result.join(' ')}" unless result.empty?
      end

      # @since 0.1.0
      # @api private
      def self.extended_command_arguments(command)
        command.arguments.map do |argument|
          "  #{argument.name.to_s.upcase.ljust(20)}\t# #{'REQUIRED ' if argument.required?}#{argument.desc}"
        end.join("\n")
      end

      # @since 0.1.0
      # @api private
      def self.extended_command_options(command)
        result = command.options.map do |option|
          name = Utils::String.dasherize(option.name)
          name = if option.boolean?
                   "[no-]#{name}"
                 else
                   "#{name}=VALUE"
                 end

          name = "#{name}, #{option.aliases.map { |a| a.start_with?('--') ? "#{a}=VALUE" : "#{a} VALUE" }.join(', ')}" unless option.aliases.empty?
          name = "  --#{name.ljust(30)}"
          name = "#{name}\t# #{option.desc}"
          name = "#{name}, default: #{option.default.inspect}" unless option.default.nil?
          name
        end

        result << "  --#{'help, -h'.ljust(30)}\t# Print this help"
        result.join("\n")
      end
    end
  end
end
