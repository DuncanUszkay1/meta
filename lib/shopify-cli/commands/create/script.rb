require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Script < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Create a script project."
        CMD_USAGE = "create script --extension_point=<ep_name> --name=<script_name>"
        CREATED_NEW_SCRIPT_MSG = "{{v}} Script created: %{folder}/src/{{green:%{script_filename}}}"
        INVALID_EXTENSION_POINT = "Incorrect extension point: %{extension_point}"
        OPERATION_FAILED_MESSAGE = "Script not created."

        options do |parser, flags|
          parser.on('--extension_point=EP_NAME') { |ep_name| flags[:ep_name] = ep_name }
          parser.on('--name=SCRIPT_NAME') { |script_name| flags[:script_name] = script_name }
        end

        def call(_args, _name)
          script_name = options.flags[:script_name]
          ep_name = options.flags[:ep_name]

          return self.class.call_help("create") unless script_name && ep_name

          language = 'ts'
          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          authenticate_partner_identity(@ctx)
          script = bootstrap(@ctx, language, ep_name, script_name)
          ScriptModule::Presentation::DependencyInstaller.call(@ctx, language, script_name, OPERATION_FAILED_MESSAGE)

          @ctx.puts(format(CREATED_NEW_SCRIPT_MSG, script_filename: script.filename, folder: script.name))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          ShopifyCli::UI::ErrorHandler.display_and_raise(invalid_extension_point_error_messages)
        rescue ScriptModule::Infrastructure::ForbiddenError => e
          ShopifyCli::UI::ErrorHandler.display_and_raise(
            failed_op: OPERATION_FAILED_MESSAGE,
            cause_of_error: e.cause_of_error,
            help_suggestion: nil
          )
        rescue ShopifyCli::ScriptModule::ScriptProjectAlreadyExistsError => e
          ShopifyCli::UI::ErrorHandler.display_and_raise(
            failed_op: OPERATION_FAILED_MESSAGE,
            cause_of_error: e.cause_of_error,
            help_suggestion: e.help_suggestion
          )
        rescue StandardError => e
          raise(ShopifyCli::Abort, e)
        end

        def self.help
          "  #{CMD_DESCRIPTION}\n" \
          "    Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}"
        end

        def self.extended_help
          "      Options:\n" \
          "      {{command:--extension_point=<name>}} Extension point name. Allowed values:
           {{cyan:discount}} and {{cyan:unit_limit_per_order}}\n" \
          "      {{command:--name=<script_name>}} Name of script.\n"
        end

        private

        def authenticate_partner_identity(ctx)
          ShopifyCli::UI::StrictSpinner.spin('Authenticating') do |spinner|
            ScriptModule::Application::AuthenticatePartnerIdentity.call(ctx)
            spinner.update_title('Authenticated')
          end
        end

        def bootstrap(ctx, language, extension_point, name)
          CLI::UI::Frame.open("Cloning into #{name}") do
            CLI::UI::Progress.progress do |bar|
              script = ScriptModule::Application::Bootstrap.call(ctx, language, extension_point, name)
              bar.tick(set_percent: 1.0)
              script
            end
          end
        end

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
