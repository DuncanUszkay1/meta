# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Bootstrap
        def self.call(ctx, language, extension_point, script_name)
          # temporary for internal preview, only discount and unit_limit_per_order EP is supported
          unless extension_point.type.eql?('discount') || extension_point.type.eql?('unit_limit_per_order')
            raise ShopifyCli::ScriptModule::Domain::InvalidExtensionPointError.new(type: extension_point.type)
          end

          ShopifyCli::Project.write(ctx, :script,
            'extension_point_type' => extension_point.type, 'script_name' => script_name)
          ShopifyCli::Finalize.request_cd(script_name)

          script = Infrastructure::ScriptRepository
            .new
            .create_script(language, extension_point, script_name)

          Infrastructure::TestSuiteRepository
            .new
            .create_test_suite(script)

          ShopifyCli::Project.write(ctx, :script,
            'extension_point_type' => extension_point.type, 'script_name' => script_name)

          script
        end
      end
    end
  end
end
