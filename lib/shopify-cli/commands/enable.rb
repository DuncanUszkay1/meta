require "shopify_cli"

module ShopifyCli
  module Commands
    class Enable < ShopifyCli::ContextualCommand
      available_in_contexts 'enable', [:script]

      CMD_DESCRIPTION = "Turn on script in development store."
      CMD_USAGE = "enable --shop_id=<dev_store_id> --API_key=<API_key>"
      ENABLING_MSG = "Enabling"
      ENABLED_MSG = "Enabled"

      OPERATION_SUCCESS_MESSAGE = "Script enabled. %{type} script %{title} in app (API key: %{api_key}) "\
                                  "is turned on in development store (shop ID: {{green:%{shop_id}}})"
      OPERATION_FAILED_MESSAGE = "Can't enable script."
      TRY_AGAIN = 'Try again.'

      APP_NOT_INSTALLED_ERROR = "Install app on development store."
      APP_SCRIPT_UNDEFINED_ERROR = "Deploy script to app."

      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--shop_id=SHOPID') { |t| flags[:shop_id] = t }
      end

      def call(args, _name)
        form = Forms::Enable.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) unless form

        shop_id = form.shop_id.to_i
        return @ctx.puts(self.class.help) unless shop_id

        api_key = form.api_key
        project = ShopifyCli::ScriptModule::ScriptProject.current
        extension_point_type = project.extension_point_type
        title = project.script_name
        configuration = '{}'

        authenticate_partner_identity(@ctx)
        enable_script(api_key, shop_id, configuration, extension_point_type, title)

        @ctx.puts(format(
          OPERATION_SUCCESS_MESSAGE,
          type: extension_point_type.capitalize,
          title: title,
          api_key: api_key,
          shop_id: shop_id
        ))
      rescue ScriptModule::Infrastructure::AppNotInstalledError
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: APP_NOT_INSTALLED_ERROR,
          help_suggestion: TRY_AGAIN
        )
      rescue ScriptModule::Infrastructure::AppScriptUndefinedError
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: APP_SCRIPT_UNDEFINED_ERROR,
          help_suggestion: nil
        )
      rescue ScriptModule::Infrastructure::ForbiddenError => e
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: e.cause_of_error,
          help_suggestion: nil
        )
      rescue ScriptModule::Infrastructure::ShopAuthenticationError => e
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: e.cause_of_error,
          help_suggestion: e.help_suggestion
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

      def enable_script(api_key, shop_id, configuration, extension_point_type, title)
        ShopifyCli::UI::StrictSpinner.spin(ENABLING_MSG) do |spinner|
          ShopifyCli::ScriptModule::Application::Enable.call(
            @ctx,
            api_key,
            shop_id,
            configuration,
            extension_point_type,
            title
          )
          spinner.update_title(ENABLED_MSG)
        end
      end
    end
  end
end
