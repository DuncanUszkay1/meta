require "shopify_cli"

module ShopifyCli
  module Commands
    class Publish < ShopifyCli::ContextualCommand
      available_in_contexts 'publish', [:script]

      CMD_DESCRIPTION = "Turn on the script in your dev store and change the values of the configuration values."
      CMD_USAGE = "publish --shop_id=<dev_store_id> --API_key=<API_key>"

      PUBLISHING_MSG = "Publishing"
      PUBLISHED_MSG = "Published"

      OPERATION_SUCCESS_MESSAGE = "Your script is published. %{type} script %{title} is published to app "\
                                  "(API key: {{green:%{api_key}}}) on store (shop ID: {{green:%{shop_id}}})"
      OPERATION_FAILED_MESSAGE = "The script didn't publish."
      TRY_AGAIN = 'Try again.'

      APP_NOT_INSTALLED_ERROR = "The app is not installed on the store."
      APP_SCRIPT_UNDEFINED_ERROR = "You haven't deployed the script to the app."
      SHOP_AUTHENTICATION_ERROR = "Unable to authenticate with the store."

      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--shop_id=SHOPID') { |t| flags[:shop_id] = t }
      end

      def call(args, _name)
        shop_id = options.flags[:shop_id].to_i
        return @ctx.puts(self.class.help) unless shop_id

        form = Forms::AppApiKey.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) unless form

        api_key = form.api_key
        project = ShopifyCli::ScriptModule::ScriptProject.current
        extension_point_type = project.extension_point_type
        title = project.script_name
        configuration = '{}'

        authenticate_partner_identity(@ctx)
        publish_script(api_key, shop_id, configuration, extension_point_type, title)

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
      rescue ScriptModule::Infrastructure::ShopAuthenticationError
        ShopifyCli::UI::ErrorHandler.display_and_raise(
          failed_op: OPERATION_FAILED_MESSAGE,
          cause_of_error: SHOP_AUTHENTICATION_ERROR,
          help_suggestion: TRY_AGAIN
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

      def publish_script(api_key, shop_id, configuration, extension_point_type, title)
        ShopifyCli::UI::StrictSpinner.spin(PUBLISHING_MSG) do |spinner|
          ShopifyCli::ScriptModule::Application::Publish.call(
            @ctx,
            api_key,
            shop_id,
            configuration,
            extension_point_type,
            title
          )
          spinner.update_title(PUBLISHED_MSG)
        end
      end
    end
  end
end
