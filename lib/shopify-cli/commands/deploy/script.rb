require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy
      class Script < ShopifyCli::Command
        CMD_DESCRIPTION = "Build the script and deploy it to app."
        CMD_USAGE = "deploy --API_key=<API_key> [--force]"

        BUILDING_MSG = "Building"
        DEPLOYING_MSG = "Deploying"
        BUILT_MSG = "Built"
        DEPLOYED_MSG = "Deployed"

        OPERATION_SUCCESS_MESSAGE = "Script deployed to app (API key: %{api_key})."
        OPERATION_FAILED_MESSAGE = "Script not deployed."

        DEPLOY_BUILD_FAILURE_MESSAGE = "Something went wrong while building the script."
        DEPLOY_HELP_SUGGESTION = "Correct the errors and try again."

        options do |parser, flags|
          parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
          parser.on('--force') { |t| flags[:force] = t }
        end

        def call(args, _name)
          form = Forms::DeployScript.ask(@ctx, args, options.flags)
          return @ctx.puts(self.class.help) unless form

          api_key = form.api_key

          project = ShopifyCli::ScriptModule::ScriptProject.current
          extension_point_type = project.extension_point_type
          script_name = project.script_name
          language = project.language

          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          extension_point = ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new
            .get_extension_point(extension_point_type)

          ScriptModule::Presentation::DependencyInstaller.call(
            @ctx,
            language,
            extension_point,
            script_name,
            OPERATION_FAILED_MESSAGE
          )
          build_script(language, extension_point_type, script_name)
          authenticate_partner_identity(@ctx)

          ShopifyCli::UI::StrictSpinner.spin(DEPLOYING_MSG) do |spinner|
            deploy_script(language, extension_point_type, script_name, api_key)
            spinner.update_title(DEPLOYED_MSG)
          end

          @ctx.puts("{{v}} #{format(OPERATION_SUCCESS_MESSAGE, api_key: api_key)}")
        rescue StandardError => e
          ShopifyCli::UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
        end

        def self.help
          "  #{CMD_DESCRIPTION}\n" \
          "    Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}"
        end

        private

        def authenticate_partner_identity(ctx)
          ShopifyCli::UI::StrictSpinner.spin('Authenticating') do |spinner|
            ScriptModule::Application::AuthenticatePartnerIdentity.call(ctx)
            spinner.update_title('Authenticated')
          end
        end

        def deploy_script(language, extension_point_type, script_name, api_key)
          ScriptModule::Application::Deploy.call(
            @ctx, language, extension_point_type, script_name, api_key, options.flags[:force]
          )
        end

        def build_script(language, extension_point_type, script_name)
          success = CLI::UI::Frame.open('Building') do
            begin
              CLI::UI::Progress.progress do |bar|
                bar.tick(set_percent: 0)
                ScriptModule::Application::Build.call(language, extension_point_type, script_name)
                bar.tick(set_percent: 1.0)
                true
              end
            rescue StandardError => e
              CLI::UI::Frame.with_frame_color_override(:red) do
                @ctx.puts("\n{{red:#{e.message}}}")
              end
              false
            end
          end

          unless success
            ShopifyCli::UI::ErrorHandler.display_and_raise(
              failed_op: OPERATION_FAILED_MESSAGE,
              cause_of_error: DEPLOY_BUILD_FAILURE_MESSAGE,
              help_suggestion: DEPLOY_HELP_SUGGESTION
            )
          end
        end
      end
    end
  end
end
