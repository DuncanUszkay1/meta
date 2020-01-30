require 'shopify_cli'

module ShopifyCli
  module Commands
    class Open < ShopifyCli::ContextualCommand
      include Helpers::OS

      prerequisite_task :tunnel
      unregister_for_context 'open' unless Project.current_context == :app

      def call(*)
        open_url!(@ctx, Project.current.app_type.open_url)
      end

      def self.help
        <<~HELP
          Open your local development app in the default browser.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} open}}
        HELP
      end
    end
  end
end
