require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class DeployScript < Form
      flag_arguments :api_key

      def ask
        self.api_key ||= ask_api_key
      end

      private

      def ask_api_key
        Helpers::Form.ask_app_api_key(organization['apps'])
      end

      def organizations
        @organizations ||= Helpers::Organizations.fetch_with_app(ctx)
      end

      def organization
        @organization ||= Helpers::Form.ask_organization(ctx, organizations)
      end
    end
  end
end
