# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Build
        def self.call(language, extension_point_type, script_name)
          script_repository = Infrastructure::ScriptRepository.new
          extension_point_repo = Infrastructure::ExtensionPointRepository.new(
            Infrastructure::ScriptService.new
          )
          extension_point = extension_point_repo.get_extension_point(extension_point_type, script_name)
          script = script_repository.get_script(language, extension_point, script_name)

          bytecode = script_repository.load_script_source(language, extension_point, script_name) do
            Infrastructure::TypeScriptWasmBuilder.new(script).build
          end

          Infrastructure::WasmBlobRepository.new.create_wasm_blob(extension_point, script, bytecode)
        end
      end
    end
  end
end
