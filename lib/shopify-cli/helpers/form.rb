require 'shopify_cli'

module ShopifyCli
  module Helpers
    class Form
      class << self
        def ask_app_api_key(apps, message: 'Which app do you want this script to belong to?')
          if apps.count == 0
            raise ShopifyCli::Abort, '{{x}} You need to create an app first.'
          elsif apps.count == 1
            apps.first["apiKey"]
          else
            CLI::UI::Prompt.ask(message) do |handler|
              apps.each { |app| handler.option(app["title"]) { app["apiKey"] } }
            end
          end
        end

        def ask_organization(ctx, organizations)
          if organizations.count == 0
            ctx.puts('Please visit https://partners.shopify.com/ to create a partners account.')
            raise ShopifyCli::Abort, '{{x}} No organizations available.'
          elsif organizations.count == 1
            ctx.puts("Organization {{green:#{organizations.first['businessName']}}}.")
            organizations.first
          else
            org_id = CLI::UI::Prompt.ask('Select organization.') do |handler|
              organizations.each { |o| handler.option(o['businessName']) { o['id'] } }
            end
            organizations.find { |o| o['id'] == org_id }
          end
        end
      end
    end
  end
end
