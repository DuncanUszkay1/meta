# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    LANGUAGES = %w(ts js json)

    module Application
      autoload :Bootstrap, "shopify-cli/script/application/bootstrap.rb"
      autoload :Build, "shopify-cli/script/application/build.rb"
      autoload :Deploy, "shopify-cli/script/application/deploy.rb"
      autoload :Test, "shopify-cli/script/application/test.rb"
      autoload :InstallDependencies, "shopify-cli/script/application/install_dependencies.rb"
      autoload :AuthenticatePartnerIdentity, "shopify-cli/script/application/authenticate_partner_identity.rb"
    end

    module Domain
      autoload :Script, "shopify-cli/script/domain/script.rb"
      autoload :ExtensionPoint, "shopify-cli/script/domain/extension_point.rb"
      autoload :ExtensionPointService, "shopify-cli/script/domain/extension_point_service.rb"
      autoload :DeployPackage, "shopify-cli/script/domain/deploy_package.rb"
      autoload :TestSuite, "shopify-cli/script/domain/test_suite.rb"

      autoload :InvalidExtensionPointError, "shopify-cli/script/domain/errors/invalid_extension_point_error.rb"
      autoload :ScriptNotFoundError, "shopify-cli/script/domain/errors/script_not_found_error.rb"
      autoload :ServiceFailureError, "shopify-cli/script/domain/errors/service_failure_error.rb"
      autoload :TestSuiteNotFoundError, "shopify-cli/script/domain/errors/test_suite_not_found_error.rb"
      autoload :DeployPackageNotFoundError, "shopify-cli/script/domain/errors/deploy_package_not_found_error.rb"
    end

    module Infrastructure
      autoload :Repository, "shopify-cli/script/infrastructure/repository.rb"
      autoload :ExtensionPointRepository, "shopify-cli/script/infrastructure/extension_point_repository.rb"
      autoload :ScriptRepository, "shopify-cli/script/infrastructure/script_repository.rb"
      autoload :DeployPackageRepository, "shopify-cli/script/infrastructure/deploy_package_repository.rb"
      autoload :TestSuiteRepository, "shopify-cli/script/infrastructure/test_suite_repository.rb"

      autoload :ScriptService, "shopify-cli/script/infrastructure/script_service.rb"
      autoload :PartnerDashboard, "shopify-cli/script/infrastructure/partner_dashboard.rb"

      autoload :ScriptBuilder, "shopify-cli/script/infrastructure/script_builder.rb"
      autoload :TypeScriptWasmBuilder, "shopify-cli/script/infrastructure/typescript_wasm_builder.rb"
      autoload :TypeScriptWasmTestRunner, "shopify-cli/script/infrastructure/typescript_wasm_test_runner.rb"

      autoload :DependencyManager, "shopify-cli/script/infrastructure/dependency_manager.rb"
      autoload :TypeScriptDependencyManager, "shopify-cli/script/infrastructure/typescript_dependency_manager.rb"

      # errors
      autoload :BuilderNotFoundError, "shopify-cli/script/infrastructure/errors/builder_not_found_error.rb"
      autoload :GraphqlError, "shopify-cli/script/infrastructure/errors/graphql_error.rb"
      autoload :ScriptServiceUserError, "shopify-cli/script/infrastructure/errors/script_service_user_error.rb"
      autoload :ScriptRedeployError, "shopify-cli/script/infrastructure/errors/script_redeploy_error.rb"
      autoload :DependencyError, "shopify-cli/script/infrastructure/errors/dependency_error.rb"
    end

    autoload :ScriptProject, "shopify-cli/script/script_project.rb"
    autoload :InvalidScriptProjectContextError, "shopify-cli/script/errors/invalid_script_project_context_error.rb"
    autoload :ScriptProjectAlreadyExistsError, "shopify-cli/script/errors/script_project_already_exists_error.rb"
  end
end
