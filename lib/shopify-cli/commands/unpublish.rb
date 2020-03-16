require "shopify_cli"

module ShopifyCli
  module Commands
    class Unpublish < ShopifyCli::ContextualCommand
      available_in_contexts 'unpublish', [:script]

      CMD_DESCRIPTION = "Turn off your script in the store."
      CMD_USAGE = "unpublish --shop_id=<dev_store_id> --API_key=<API_key>"

      UNPUBLISHING_MSG = "Unpublishing"
      UNPUBLISHED_MSG = "Unpublished"

      OPERATION_SUCCESS_MESSAGE = "Script disabled. Script is turned off in development store."
      OPERATION_FAILED_MESSAGE = "Can't disable script."

      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--shop_id=SHOPID') { |t| flags[:shop_id] = t }
      end

      def call(args, _name)
        form = Forms::Publish.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) unless form

        shop_id = form.shop_id.to_i
        return @ctx.puts(self.class.help) unless shop_id

        api_key = form.api_key
        project = ShopifyCli::ScriptModule::ScriptProject.current
        extension_point_type = project.extension_point_type

        authenticate_partner_identity(@ctx)
        unpublish_script(api_key, shop_id, extension_point_type)

        @ctx.puts(OPERATION_SUCCESS_MESSAGE)

      rescue ScriptModule::Infrastructure::AppNotInstalledError,
             ScriptModule::Infrastructure::ShopScriptUndefinedError,
             ScriptModule::Infrastructure::ShopAuthenticationError => e
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: e.cause_of_error,
          help_suggestion: e.help_suggestion
        )
      rescue ScriptModule::Infrastructure::ForbiddenError => e
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: e.cause_of_error,
          help_suggestion: nil
        )
      rescue StandardError => e
        raise(ShopifyCli::Abort, e)
      end

      def self.help
        "  #{CMD_DESCRIPTION}\n"\
        "    Usage: {{command:#{TOOL_NAME} #{CMD_USAGE}}}"
      end

      private

      def authenticate_partner_identity(ctx)
        ShopifyCli::UI::StrictSpinner.spin('Authenticating') do |spinner|
          ScriptModule::Application::AuthenticatePartnerIdentity.call(ctx)
          spinner.update_title('Authenticated')
        end
      end

      def unpublish_script(api_key, shop_id, extension_point_type)
        ShopifyCli::UI::StrictSpinner.spin(UNPUBLISHING_MSG) do |spinner|
          ShopifyCli::ScriptModule::Application::Unpublish.call(
            @ctx,
            api_key,
            shop_id,
            extension_point_type,
          )
          spinner.update_title(UNPUBLISHED_MSG)
        end
      end
    end
  end
end
