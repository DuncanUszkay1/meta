require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadSystem < ShopifyCli::Command
      def call(_args, _name)
        @ctx.done("Reloading #{TOOL_FULL_NAME} from #{ShopifyCli::INSTALL_DIR}")
        ShopifyCli::Finalize.reload_shopify_from(ShopifyCli::INSTALL_DIR)
      end

      def self.help
        "  Reload the installed instance of Shopify App CLI. " \
        "This command is intended for development work on the CLI itself.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} load-system}}"
      end
    end
  end
end
