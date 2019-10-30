# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class WasmBlobRepository < Repository
        def create_wasm_blob(extension_point, script, bytecode)
          base = "#{src_base(extension_point, script.name)}/build"
          FileUtils.mkdir_p(base)
          File.write("#{base}/#{script.name}.wasm", bytecode)

          id = wasm_blob_id(extension_point, script.name)
          Domain::WasmBlob.new(id, extension_point, script.name, bytecode)
        end

        def get_wasm_blob(_language, extension_point, script_name)
          id = wasm_blob_id(extension_point, script_name)

          raise ArgumentError,
            "#{script_name}.wasm file not found for:
            #{extension_point_type} #{script_name}" unless File.exist?(id)

          Domain::WasmBlob.new(id, extension_point, script_name, File.read(id))
        end

        private

        def src_base(extension_point, script_name)
          "#{SOURCE_PATH}/#{extension_point.type}/#{script_name}"
        end

        def wasm_blob_id(extension_point, script_name)
          "#{src_base(extension_point, script_name)}/build/#{script_name}.wasm"
        end
      end
    end
  end
end
