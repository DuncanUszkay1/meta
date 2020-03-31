require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Script < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Create a script project."
        CMD_USAGE = "create script <name>"
        INVALID_EXTENSION_POINT = "Incorrect extension point: %{extension_point}"
        OPERATION_FAILED_MESSAGE = "Script not created."

        DIRECTORY_CHANGED_MSG = "{{v}} Changed to project directory: {{green:%{folder}}}"
        OPERATION_SUCCESS_MESSAGE = "{{v}} Script created: {{green:%{script_id}}}"

        options do |parser, flags|
          parser.on('--extension_point=EP_NAME') { |ep_name| flags[:ep_name] = ep_name }
        end

        def call(args, _name)
          script_name = args.first
          ep_name = options.flags[:ep_name]

          return @ctx.puts(self.class.help) unless script_name && ep_name

          language = 'ts'
          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          extension_point = ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new
            .get_extension_point(ep_name)

          ShopifyCli::ScriptModule::ScriptProject.create(script_name)

          @ctx.root = File.join(@ctx.root, script_name)

          script = ScriptModule::Application::Bootstrap.call(
            @ctx,
            language,
            extension_point,
            script_name,
            OPERATION_FAILED_MESSAGE
          )

          @ctx.puts(format(DIRECTORY_CHANGED_MSG, folder: @ctx.root))
          @ctx.puts(format(OPERATION_SUCCESS_MESSAGE, script_id: script.id))
        rescue StandardError => e
          ShopifyCli::UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
        end

        def self.help
          "  #{CMD_DESCRIPTION}\n" \
          "    Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}"
        end

        def self.extended_help
          allowed_values = "{{cyan:discount}} and {{cyan:unit_limit_per_order}}"
          "      Options:\n" \
          "      {{command:--extension_point=<name>}} Extension point name. Allowed values: #{allowed_values}.\n"
        end

        private

        def invalid_extension_point_error_messages
          {
            failed_op: OPERATION_FAILED_MESSAGE,
            cause_of_error: 'Incorrect extension point.',
            help_suggestion: 'Allowed values: discount and unit_limit_per_order.',
          }
        end
      end
    end
  end
end
