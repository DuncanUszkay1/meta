require 'cli/ui'

module ShopifyCli
  module UI
    module ErrorHandler
      def self.display(failed_op:, cause_of_error:, help_suggestion:)
        $stderr.puts(CLI::UI.fmt("{{red:{{x}} Error}}"))
        full_msg = failed_op ? failed_op.dup : ""
        full_msg << " #{cause_of_error}" if cause_of_error
        full_msg << " #{help_suggestion}" if help_suggestion
        $stderr.puts(CLI::UI.fmt(full_msg.strip))
      end

      def self.display_and_raise(failed_op: nil, cause_of_error: nil, help_suggestion: nil)
        display(failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion)
        raise(ShopifyCli::AbortSilent)
      end

      def self.pretty_print_and_raise(e, failed_op: nil)
        messages = error_messages(e)
        raise e if messages.nil?
        display_and_raise(failed_op: failed_op, **messages)
      end

      def self.error_messages(e)
        case e
        when ScriptModule::InvalidScriptProjectContextError
          {
            cause_of_error: "Your .shopify-cli.yml file is not correct.",
            help_suggestion: "See https://help.shopify.com/en/",
          }
        when ScriptModule::ScriptProjectAlreadyExistsError
          {
            cause_of_error: "Directory with the same name as the script already exists.",
            help_suggestion: "Use different script name and try again.",
          }
        when ScriptModule::Domain::InvalidExtensionPointError
          {
            cause_of_error: "Invalid extension point #{e.type}",
            help_suggestion: "Allowed values: discount and unit_limit_per_order.",
          }
        when ScriptModule::Domain::ScriptNotFoundError
          {
            cause_of_error: "Couldn't find script #{e.script_name} for extension point #{e.extension_point_type}",
          }
        when ScriptModule::Infrastructure::AppNotInstalledError
          {
            cause_of_error: "App not installed on development store.",
          }
        when ScriptModule::Infrastructure::AppScriptUndefinedError
          {
            cause_of_error: "Deploy script to app.",
          }
        when ScriptModule::Infrastructure::ForbiddenError
          {
            cause_of_error: "You do not have permission to do this action.",
          }
        when ScriptModule::Infrastructure::GraphqlError
          {
            cause_of_error: "An error was returned: #{e.errors.join(', ')}.",
            help_suggestion: "\nReview the error and try again.",
          }
        when ScriptModule::Infrastructure::ScriptRedeployError
          {
            cause_of_error: "Script with the same extension point already exists on app (API key: #{e.api_key}).",
            help_suggestion: "Use {{cyan:--force}} to replace the existing script.",
          }
        when ScriptModule::Infrastructure::ShopAuthenticationError
          {
            cause_of_error: "Unable to authenticate with the store.",
            help_suggestion: "Try again.",
          }
        when ScriptModule::Infrastructure::ShopScriptUndefinedError
          {
            cause_of_error: "Script is already turned off in development store.",
          }
        end
      end
    end
  end
end
