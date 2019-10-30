# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Bootstrap
        def self.call(language, extension_point_type, script_name)
          extension_point_repository = Infrastructure::ExtensionPointRepository.new(
            Infrastructure::ScriptService.new
          )
          extension_point = extension_point_repository.get_extension_point(extension_point_type, script_name)

          script_repo = Infrastructure::ScriptRepository.new
          script_repo.create_script(language, extension_point, script_name)
        end
      end
    end
  end
end
