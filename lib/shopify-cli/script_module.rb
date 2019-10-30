require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      autoload :Bootstrap, "shopify-cli/scripts/application/bootstrap.rb"
      autoload :Build, "shopify-cli/scripts/application/build.rb"
      autoload :Deploy, "shopify-cli/scripts/application/deploy.rb"
      autoload :GenerateFromSchema, "shopify-cli/scripts/application/generate_from_schema.rb"
    end

    module Domain
      autoload :Script, "shopify-cli/scripts/domain/script.rb"
      autoload :ExtensionPoint, "shopify-cli/scripts/domain/extension_point.rb"
      autoload :ExtensionPointService, "shopify-cli/scripts/domain/extension_point_service.rb"
      autoload :WasmBlob, "shopify-cli/scripts/domain/wasm_blob.rb"
      autoload :Configuration, "shopify-cli/scripts/domain/configuration.rb"

      autoload :InvalidExtensionPointError, "shopify-cli/scripts/domain/errors/invalid_extension_point_error.rb"
      autoload :ScriptNotFoundError, "shopify-cli/scripts/domain/errors/script_not_found_error.rb"
      autoload :ConfigurationNotFoundError, "shopify-cli/scripts/domain/errors/configuration_file_not_found_error.rb"
      autoload :ServiceFailureError, "shopify-cli/scripts/domain/errors/service_failure_error.rb"
    end

    module Infrastructure
      autoload :Repository, "shopify-cli/scripts/infrastructure/repository.rb"
      autoload :ExtensionPointRepository, "shopify-cli/scripts/infrastructure/extension_point_repository.rb"
      autoload :ScriptRepository, "shopify-cli/scripts/infrastructure/script_repository.rb"
      autoload :ConfigurationRepository, "shopify-cli/scripts/infrastructure/configuration_repository.rb"
      autoload :WasmBlobRepository, "shopify-cli/scripts/infrastructure/wasm_blob_repository.rb"

      autoload :ScriptService, "shopify-cli/scripts/infrastructure/script_service.rb"

      autoload :TypeScriptWasmBuilder, "shopify-cli/scripts/infrastructure/typescript_wasm_builder.rb"
      autoload :GraphQLTypeScriptBuilder, "shopify-cli/scripts/infrastructure/graphql_typescript_builder.rb"
    end
  end
end
