require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate < ShopifyCli::ContextualCommand
      prerequisite_task :schema

      autoload :Resource, 'shopify-cli/commands/populate/resource'
      subcommand :Product, 'products', 'shopify-cli/commands/populate/product'
      subcommand :Customer, 'customers', 'shopify-cli/commands/populate/customer'
      subcommand :DraftOrder, 'draftorders', 'shopify-cli/commands/populate/draft_order'

      available_in_contexts 'populate', [:app]

      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        "  Add example objects to your development store.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} populate [ products | customers | draftorders ]}}"
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:products [options]}}: Add example products to the store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate products}}

            {{cyan:customers [options]}}: Add example customers to the store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate customers}}

            {{cyan:draftorders [options]}}: Add example orders to the store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate draftorders}}

          {{bold:Options:}}

            {{cyan:--count [integer]}}: Number of objects to add. Default is 5.
            {{cyan:--silent}}: Hide the output.

          {{bold:Examples:}}

            {{cyan:shopify populate products}}
              Add 5 example products to your store.

            {{cyan:shopify populate customers --count 30}}
              Add 30 example customers to your store.

            {{cyan:shopify populate draftorders}}
              Add 5 example orders to your store.
        HELP
      end
    end
  end
end
