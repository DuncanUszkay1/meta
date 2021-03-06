# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    attr_writer :ctx
    attr_accessor :options

    class << self
      attr_writer :ctx

      def call(args, command_name)
        subcommand, resolved_name = subcommand_registry.lookup_command(args.first)
        if subcommand
          subcommand.ctx = @ctx
          subcommand.call(args, resolved_name)
        else
          cmd = new
          cmd.ctx = @ctx
          cmd.options = Options.new
          cmd.options.parse(@_options, args)
          return call_help(command_name) if cmd.options.help
          cmd.call(args, command_name)
        end
      rescue OptionParser::InvalidOption
        ShopifyCli::UI::ErrorHandler.display(
          failed_op: 'Command can’t run because there’s something wrong with a subcommand or option name.',
          cause_of_error: 'Often there’s a typo in the name or the name is incorrect.',
          help_suggestion: 'Correct the command and try again.'
        )
        call_help(command_name)
        raise AbortSilent
      end

      def options(&block)
        @_options = block
      end

      def subcommand(const, cmd, path = nil)
        autoload(const, path) if path
        subcommand_registry.add(->() { const_get(const) }, cmd)
      end

      def subcommand_registry
        @subcommand_registry ||= CLI::Kit::CommandRegistry.new(
          default: nil,
          contextual_resolver: nil,
        )
      end

      def execute_subcommands
        subcommand_registry.resolved_commands.each_value.map { |subcommand| yield subcommand }
      end

      def prerequisite_task(*tasks)
        tasks.each do |task|
          prerequisite_tasks[task] = ShopifyCli::Tasks::Registry[task]
        end
      end

      def prerequisite_tasks
        @prerequisite_tasks ||= {}
      end

      def call_help(name)
        help = Commands::Help.new(@ctx)
        help.call([name], nil)
      end

      def needs_contextual_resolution?
        false
      end

      def help
        helps = execute_subcommands(&:help)
        helps&.join("\n")
      end

      def extended_help
        extended_helps = execute_subcommands do |subcommand|
          if subcommand.respond_to?(:extended_help)
            subcommand.extended_help
          end
        end
        extended_helps&.join("\n")
      end

      def all_help
        if subcommand_registry.resolved_commands.empty?
          help
        else
          all_helps = subcommand_registry.resolved_commands.each_value.map do |subcommand|
            help_text = subcommand.help
            help_text.concat("\n#{subcommand.extended_help}") if subcommand.respond_to?(:extended_help)
          end
          all_helps&.join("\n")
        end
      end
    end

    def initialize(ctx = nil)
      @ctx = ctx || ShopifyCli::Context.new
    end
  end
end
