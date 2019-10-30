# frozen_string_literal: true

require "test_helper"
require "tmpdir"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder do
  let(:script_name) { "foo" }
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("id", "discount", "schema") }
  let(:installation_base_path) { ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH }
  let(:script_root) { "#{installation_base_path}/#{extension_point.type}/#{script_name}" }
  let(:language) { "ts" }
  let(:configuration) { MiniTest::Mock.new }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script }
  let(:discount_script) { script.new(script_root, script_name, extension_point, configuration, language) }
  let(:assembly_index) do
    "export function shopify_runtime_allocate(size: u32): ArrayBuffer { return new ArrayBuffer(size); }
import { run } from \"./#{script_name}\"
export { run };"
  end
  let(:tsconfig) do
    "{
  \"extends\": \"./node_modules/assemblyscript/std/assembly.json\",
}"
  end

  subject { ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder.new(discount_script) }

  describe "build" do
    it "should write the entry and tsconfig files, install assembly script and trigger the compilation process" do
      File.expects(:write).with("assembly.ts", assembly_index)
      File.expects(:write).with("tsconfig.json", tsconfig)
      File.expects(:read).with("build/#{script_name}.wasm")

      ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder
        .any_instance
        .expects(:system)
        .at_most(2)
        .returns(true)

      subject.build
    end
  end
end
