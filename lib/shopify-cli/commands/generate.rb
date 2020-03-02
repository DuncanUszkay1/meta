require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate < ShopifyCli::ContextualCommand
      subcommand :Page, 'page', 'shopify-cli/commands/generate/page'
      subcommand :Billing, 'billing', 'shopify-cli/commands/generate/billing'
      subcommand :Webhook, 'webhook', 'shopify-cli/commands/generate/webhook'

      available_in_contexts 'generate', [:app]

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        "  Generate code for resources in your app.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [ page | billing | webhook ]}}"
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:page}}: Generate a page in your app.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate page <pagename>}} or
                      {{command:#{ShopifyCli::TOOL_NAME} generate page <pagename> --type=TYPE}}
              Types:
              {{cyan:empty-state}}: generate a page with an empty state
              {{underline:https://polaris.shopify.com/components/structure/empty-state}}

              {{cyan:list}}: generate a page with a Resource List, generally used as an index page
              {{underline:https://polaris.shopify.com/components/lists-and-tables/resource-list}}

              {{cyan:two-column}}: generate a page with a two column card layout, generally used for details
              {{underline:https://polaris.shopify.com/components/structure/layout}}

              {{cyan:annotated}}: generate a page with a description and card layout, generally used for settings
              {{underline:https://polaris.shopify.com/components/structure/layout}}

            {{cyan:billing}}: Generate code to enable charging for your app using the Shopify Admin Billing API.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing}}

            {{cyan:webhook}}: Generate and register a webhook that listens for the specified Shopify store event.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook [type]}}

          {{bold:Examples:}}

            {{cyan:shopify generate page onboarding}}
              Generate a page in your app with a URL route of /onboarding.

            {{cyan:shopify generate webhook}}
              Show a list of all available webhooks in your terminal.

            {{cyan:shopify generate webhook PRODUCTS_CREATE}}
              Generate and register a webhook that will be called every time a product is created on your store.
        HELP
      end

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          raise(ShopifyCli::Abort, CLI::UI.fmt(response(stat.exitstatus, name)))
        end
      end

      def self.response(code, name)
        case code
        when 1
          "{{x}} Error generating #{name}"
        when 2
          "{{x}} A page with this name #{name} already exists."
        else
          '{{x}} Error'
        end
      end
    end
  end
end
