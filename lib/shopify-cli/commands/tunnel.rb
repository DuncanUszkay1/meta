# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Tunnel < ShopifyCli::ContextualCommand
      available_in_contexts 'tunnel', [:app]

      def call(args, _name)
        subcommand = args.shift
        task = ShopifyCli::Tasks::Tunnel.new
        case subcommand
        when 'start'
          task.call(@ctx)
        when 'stop'
          task.stop(@ctx)
        when 'auth'
          token = args.shift
          task.auth(@ctx, token)
        else
          puts CLI::UI.fmt(self.class.help)
        end
      end

      def self.help
        "  Start or stop an http tunnel to your local development app using ngrok.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel [ auth | start | stop ]}}"
      end

      def self.extended_help
        "  {{bold:Subcommands:}}\n\n" \
        "  {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to allow connecting \n" \
        "with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} auth <token>}}\n\n" \
        "  {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel start}}\n\n" \
        "  {{cyan:stop}}: Stops the ngrok tunnel.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel stop}}"
      end
    end
  end
end
