require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class PartnerDashboard
        include SmartProperties

        property! :ctx, accepts: ShopifyCli::Context

        def authenticate
          Helpers::PkceToken.read(ctx)
        end
      end
    end
  end
end
