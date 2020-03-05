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
        apps = Helpers::Organizations.fetch_apps(ctx)
        Helpers::Form.ask_app_api_key(apps)
      end
    end
  end
end
