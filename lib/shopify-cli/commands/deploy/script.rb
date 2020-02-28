require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy
      class Script < ShopifyCli::Command
        CMD_DESCRIPTION = "Build the script and deploy it to the app."
        CMD_USAGE = "deploy --API_key=<API_key> [--force]"

        BUILDING_MSG = "Building"
        DEPLOYING_MSG = "Deploying"
        BUILT_MSG = "Built"
        DEPLOYED_MSG = "Deployed"

        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"
        OPERATION_SUCCESS_MESSAGE = "Your script is deployed to the app (API key: {{green:%{api_key}}})."
        OPERATION_FAILED_MESSAGE = "The script didn't deploy."
        INVALID_EXTENSION_POINT_MESSAGE = "The extension point option is not correct."
        SCRIPT_NOT_FOUND = "Could not find script %{script_name} for extension point %{extension_point}"
        SCRIPT_REDEPLOY_ERROR = "{{x}} {{red:Error}}\nThe script didn't deploy. A script with this extension "\
                                  "point already exists on app (%{api_key}). Use the --force option to overwrite "\
                                  "the existing script with this new script."
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

          install_dependencies(@ctx, language, script_name)
          build_script(language, extension_point_type, script_name)
          authenticate_partner_identity(@ctx)

          ShopifyCli::UI::StrictSpinner.spin(DEPLOYING_MSG) do |spinner|
            deploy_script(language, extension_point_type, script_name, api_key)
            spinner.update_title(DEPLOYED_MSG)
          end

          @ctx.puts("{{v}} #{format(OPERATION_SUCCESS_MESSAGE, api_key: api_key)}")
        rescue ScriptModule::Infrastructure::ScriptRedeployError
          @ctx.puts(format(SCRIPT_REDEPLOY_ERROR, api_key: api_key))
        rescue ScriptModule::Domain::ScriptNotFoundError
          @ctx.puts(format(SCRIPT_NOT_FOUND, script_name: script_name, extension_point: extension_point_type))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          @ctx.puts(format(INVALID_EXTENSION_POINT, extension_point: extension_point_type))
        rescue StandardError => e
          raise(ShopifyCli::Abort, e)
        end

        def self.help
          "  #{CMD_DESCRIPTION}\n" \
          "    Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}"
        end

        private

        def install_dependencies(ctx, language, script_name)
          CLI::UI::Frame.open("Installing dependencies with npm") do
            ShopifyCli::UI::StrictSpinner.spin('dependencies installing') do |spinner|
              ScriptModule::Application::InstallDependencies.call(ctx, language, script_name)
              spinner.update_title('dependencies installed')
            end
          end
          @ctx.puts("{{v}} Dependencies installed")
        end

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
