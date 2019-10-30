# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Deploy
        def self.call(language, extension_point, script_name, shop_id = nil)
          script_service = Infrastructure::ScriptService.new
          extension_point_repository = Infrastructure::ExtensionPointRepository.new(script_service)
          extension_point = extension_point_repository.get_extension_point(extension_point, script_name)

          Infrastructure::WasmBlobRepository.new
            .get_wasm_blob(language, extension_point, script_name)
            .deploy(script_service, shop_id)
        end
      end
    end
  end
end
