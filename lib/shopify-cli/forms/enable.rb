require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class Enable < Form
      flag_arguments :api_key, :shop_id

      def ask
        self.api_key ||= ask_api_key
        self.shop_id ||= ask_shop_id
      end

      private

      def ask_api_key
        Helpers::Form.ask_app_api_key(organization['apps'], message: 'Which app is the script deployed to?')
      end

      def organizations
        @organizations ||= Helpers::Organizations.fetch_with_app(ctx)
      end

      def organization
        @organization ||= Helpers::Form.ask_organization(ctx, organizations)
      end

      def ask_shop_id
        if organization['stores'].count == 0
          ctx.puts('{{x}} No development stores available.')
          ctx.puts("Visit {{underline:https://partners.shopify.com/#{organization['id']}/stores}} to create one.")
          raise ShopifyCli::Abort
        elsif organization['stores'].count == 1
          store = organization['stores'].first
          ctx.puts("Using development store {{green:#{store['shopDomain']}}}.")
          store['shopId']
        else
          domain = CLI::UI::Prompt.ask(
            'Which development store is the app installed on?',
            options: organization["stores"].map { |s| s["shopDomain"] }
          )
          organization['stores'].find { |s| s["shopDomain"] == domain }["shopId"]
        end
      end
    end
  end
end
