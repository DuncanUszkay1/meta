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
          "  Deploy the current app project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) \n" \
          "is currently the only option, but more will be added in the future.\n" \
          "    Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy [heroku]}}"
        end
      end
    end
  end
end
