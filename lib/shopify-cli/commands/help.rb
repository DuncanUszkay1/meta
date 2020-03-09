require 'shopify_cli'

module ShopifyCli
  module Commands
    class Help < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
        if command && command != 'help'
          print_command_specific_help(command)
        else
          print_all_help
        end
      end

      private

      def print_command_specific_help(command)
        return print_not_found(command) unless Registry.exist?(command)

        cmd_klass, _name = Registry.lookup_command(command)
        return print_not_found(command) unless cmd_klass

        print_command_name(command)
        output = help_output(cmd_klass)
        @ctx.page(output)
      end

      def print_all_help
        # a line break before output aids scanning/readability
        puts ""
        @ctx.puts('{{bold:Available commands}}')
        @ctx.puts('Run {{command:shopify [command] --help}} to get information about a command.')
        puts ""

        # need to do this once to allow contextual commands to update the command registry
        ShopifyCli::Commands::Registry.resolved_commands

        ShopifyCli::Commands::Registry.resolved_commands.sort.each do |name, klass|
          next if name == 'help' || klass.nil?
          print_command_name(name)

          if (help = klass.help)
            puts CLI::UI.fmt(help)
          end
          puts ""
        end
      end

      def print_not_found(name)
        @ctx.puts("Command #{name} not found.")
        print_all_help
      end

      def print_command_name(name)
        if name.eql?('create')
          subcommand_names = ShopifyCli::Commands::Create.subcommand_registry.command_names.join(' | ')
          puts CLI::UI.fmt("{{command:#{ShopifyCli::TOOL_NAME} #{name} #{subcommand_names}}}")
        else
          puts CLI::UI.fmt("{{command:#{ShopifyCli::TOOL_NAME} #{name}}}")
        end
      end

      def help_output(cmd)
        if cmd.subcommand_registry.command_names.empty?
          output = cmd.help
          if cmd.respond_to?(:extended_help)
            output += "\n"
            output + cmd.extended_help
          end
        else
          cmd.all_help
        end
      end
    end
  end
end
