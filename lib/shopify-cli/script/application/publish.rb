# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Publish
        # rubocop:disable Metrics/ParameterLists
        def self.call(ctx, api_key, shop_id, configuration, extension_point_type, title)
          script_service = Infrastructure::ScriptService.new(ctx: ctx)
          script_service.publish(
            api_key: api_key,
            shop_id: shop_id,
            configuration: configuration,
            extension_point_type: extension_point_type,
            title: title
          )
        end
        # rubocop:enable Metrics/ParameterLists
      end
    end
  end
end
