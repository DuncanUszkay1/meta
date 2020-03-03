require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy
      class App < ShopifyCli::Command
        autoload :Heroku, 'shopify-cli/commands/deploy/app/heroku'

        def call(args, _name)
          subcommand = args.shift
          case subcommand
          when 'heroku'
            Heroku.call(@ctx, args)
          else
            @ctx.puts(self.class.help)
          end
        end

        def self.help
          "  Deploy your app to your hosting service.\n" \
          "    Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy [heroku]}}"
        end
      end
    end
  end
end
