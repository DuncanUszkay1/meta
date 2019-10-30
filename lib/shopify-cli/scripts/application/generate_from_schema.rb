# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class GenerateFromSchema
        def self.generate_config_from_schema(extension_point_type, script_name)
          Infrastructure::ConfigurationRepository.new
            .generate_configuration_types_from_schema(
              extension_point_type,
              script_name
            )
        end
      end
    end
  end
end
