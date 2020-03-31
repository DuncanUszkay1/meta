# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Bootstrap
        def self.call(ctx, language, extension_point, script_name, operation_failed_message)
          ShopifyCli::Project.write(ctx, :script,
            'extension_point_type' => extension_point.type, 'script_name' => script_name)

          ShopifyCli::ScriptModule::Application::ProjectDependencies.bootstrap(
            ctx,
            language,
            extension_point,
            script_name
          )

          ScriptModule::Presentation::DependencyInstaller.call(
            ctx,
            language,
            extension_point,
            script_name,
            operation_failed_message
          )

          script = Infrastructure::ScriptRepository.new.create_script(language, extension_point, script_name)

          Infrastructure::TestSuiteRepository.new.create_test_suite(script)

          ShopifyCli::Finalize.request_cd(script_name)

          script
        end
      end
    end
  end
end
