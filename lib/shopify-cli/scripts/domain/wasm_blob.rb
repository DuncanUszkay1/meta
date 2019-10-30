# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class WasmBlob
        attr_reader :id
        attr_reader :extension_point
        attr_reader :script_name
        attr_reader :bytecode

        def initialize(id, extension_point, script_name, bytecode)
          @id = id
          @extension_point = extension_point
          @script_name = script_name
          @bytecode = bytecode
        end

        def deploy(script_service, shop_id)
          Dir.mktmpdir do |temp_dir|
            Dir.chdir(temp_dir) do
              File.write("build.wasm", @bytecode)
              script_service.deploy(@extension_point.type, @extension_point.schema_file, @script_name,
                File.open("build.wasm"), shop_id)
            end
          end
        end
      end
    end
  end
end
