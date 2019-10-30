require 'shopify_cli'

module ShopifyCli
  module Commands
    class Scripts < ShopifyCli::Command
      subcommand :Create, 'create', 'shopify-cli/commands/scripts/create'
      subcommand :Deploy, 'deploy', 'shopify-cli/commands/scripts/deploy'
      subcommand :GenerateFromSchema, 'generate-from-schema', 'shopify-cli/commands/scripts/generate_from_schema'

      def call(*)
        @ctx.puts(self.class.help)
      end

      # TODO: fix help description text
      def self.help
        <<~HELP
          Development with script V2
            Usage: {{command:#{ShopifyCli::TOOL_NAME} scripts [ create | deploy | generate-from-schema ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:create}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} scripts create <extension point> <script name>}}

            {{cyan:deploy}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} scripts deploy <extension point> <script name>}}

            {{cyan:generate-from-schema}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} scripts generate-from-schema <extension point> <script name> --config}}
        HELP
      end
    end
  end
end
