require 'shopify_cli'

module ShopifyCli
  module Commands
    class Update < ShopifyCli::Command
      def self.help
        "  Update Shopify App CLI to the latest version.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} update}}"
      end

      def call(_args, _name)
        ShopifyCli::Update.check_now(restart_command_after_update: false, ctx: @ctx)
      end
    end
  end
end
