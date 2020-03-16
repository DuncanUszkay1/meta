# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Disable
        def self.call(ctx, api_key, shop_id, extension_point_type)
          script_service = Infrastructure::ScriptService.new(ctx: ctx)
          script_service.disable(
            api_key: api_key,
            shop_id: shop_id,
            extension_point_type: extension_point_type,
          )
        end
      end
    end
  end
end
