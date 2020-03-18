# frozen_string_literal: true
require "tmpdir"
require "fileutils"

TSCONFIG_FILE = "tsconfig.json"
TSCONFIG = "{
  \"extends\": \"./node_modules/assemblyscript/std/assembly.json\",
}"

META_FILE_BASE = "__shopify_meta" # contains abort function and allocate function
META_FILE_NAME = "#{META_FILE_BASE}.ts"

META_FILE_CONTENTS = <<~HEREDOC
  import { Console } from "as-wasi";

  export function abort(
    message: string | null,
    fileName: string | null,
    lineNumber: u32,
    columnNumber: u32
  ): void {
    let errorMsg = "Error!";
    if (message != null) {
      errorMsg += " message: " + message! + ", ";
    }
    if (fileName != null) {
      errorMsg += " filename: " + fileName! + ", ";
    }
    errorMsg += " line number: " + lineNumber.toString() + ", ";
    errorMsg += " column number: " + columnNumber.toString();
    Console.error(errorMsg);
  }

  export function shopify_runtime_allocate(size: u32): ArrayBuffer {
    return new ArrayBuffer(size);
  }
HEREDOC

GQL_BUILDER = "GraphQLBuilder.ts"
GQL_TRANSFORM = "#{File.dirname(__FILE__)}/#{GQL_BUILDER}"
ASM_SCRIPT_OPTIMIZED = "npx asc %{script}.ts #{META_FILE_NAME} -b build/%{script}.wasm --sourceMap --validate \
--optimize --use abort=#{META_FILE_BASE}/abort --runtime none --transform=./#{GQL_BUILDER} --lib=../node_modules"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptWasmBuilder
        attr_reader :script

        def initialize(script)
          @script = script
        end

        def build
          prepare
          compile
          [bytecode, schema]
        end

        def compiled_type
          "wasm"
        end

        private

        def prepare
          File.write(META_FILE_NAME, META_FILE_CONTENTS)
          File.write(TSCONFIG_FILE, TSCONFIG)
          FileUtils.cp(GQL_TRANSFORM, GQL_BUILDER)
        end

        def compile
          out, status = CLI::Kit::System.capture2e(format(ASM_SCRIPT_OPTIMIZED, script: script.name))
          raise Domain::ServiceFailureError, out unless status.success?
        end

        def bytecode
          File.read("build/#{script.name}.wasm")
        end

        def schema
          File.read("schema")
        end
      end
    end
  end
end
