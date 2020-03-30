require "shopify_cli"

module ShopifyCli
  module Commands
    class Test < ShopifyCli::ContextualCommand
      available_in_contexts 'test', [:script]

      CMD_DESCRIPTION = "Runs unit tests on your script."
      RUNNING_MSG = "Running tests"
      CMD_USAGE = "test"
      OPERATION_FAILED_MESSAGE = "Tests didn't run or they ran with failures."
      OPERATION_SUCCESS_MESSAGE = "Tests finished."
      TEST_HELP_SUGGESTION = 'Correct the errors and try again.'

      private_constant :CMD_DESCRIPTION, :RUNNING_MSG, :CMD_USAGE, :OPERATION_FAILED_MESSAGE,
        :OPERATION_SUCCESS_MESSAGE, :TEST_HELP_SUGGESTION

      def call(_args, _name)
        project = ShopifyCli::ScriptModule::ScriptProject.current
        extension_point_type = project.extension_point_type
        script_name = project.script_name
        language = project.language

        extension_point = ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository
          .new
          .get_extension_point(extension_point_type)

        ScriptModule::Presentation::DependencyInstaller.call(@ctx, language, extension_point, script_name, OPERATION_FAILED_MESSAGE)

        @ctx.setenv("FORCE_COLOR", "1") # without this, aspect output is not in color :(
        result = CLI::UI::Frame.open(RUNNING_MSG) do
          ScriptModule::Application::Test.call(@ctx, language, extension_point_type, script_name)
        end
        if result.success?
          @ctx.puts("{{v}} #{OPERATION_SUCCESS_MESSAGE}")
        else
          ShopifyCli::UI::ErrorHandler.display_and_raise(
            failed_op: OPERATION_FAILED_MESSAGE,
            cause_of_error: nil,
            help_suggestion: TEST_HELP_SUGGESTION
          )
        end
      rescue StandardError => e
        ShopifyCli::UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
      end

      def self.help
        "  #{CMD_DESCRIPTION}\n    Usage: {{command:#{TOOL_NAME} #{CMD_USAGE}}}"
      end
    end
  end
end
