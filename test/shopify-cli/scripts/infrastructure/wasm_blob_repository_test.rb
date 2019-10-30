# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::WasmBlobRepository do
  let(:language) { "ts" }
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("id", "discount", "schema") }

  let(:script_name) { "foo" }
  let(:script_id) { "ID" }
  let(:script_language) { "java" }
  let(:configuration) { MiniTest::Mock.new }
  let(:scripts) { ShopifyCli::ScriptModule::Domain::Script }
  let(:script) { scripts.new(script_id, script_name, extension_point, configuration, script_language) }
  let(:source_path) { ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH }
  subject { ShopifyCli::ScriptModule::Infrastructure::WasmBlobRepository.new }

  describe ".get_wasm_blob" do
    it "should return the wasm blob for an specific extension point and script" do
      id = "#{source_path}/#{extension_point.type}/#{script_name}/build/#{script_name}.wasm"

      File.expects(:exist?).at_least_once.returns(true)
      File.expects(:read).with(id)
      blob = subject.get_wasm_blob("ts", extension_point, script_name)

      assert_equal id, blob.id
    end
  end

  describe ".create_wasm_blob" do
    let(:bytecode) { "BYTECODE" }
    let(:schema_root) { "#{source_path}/#{extension_point.type}/#{script_name}" }
    let(:build_dir) { "#{schema_root}/build" }
    let(:build_file) { "#{build_dir}/#{script_name}.wasm" }

    it "should create a valid wasm blob and return it" do
      FileUtils.expects(:mkdir_p).with(build_dir)
      File.expects(:write).with(build_file, bytecode)
      blob = subject.create_wasm_blob(extension_point, script, bytecode)
      assert_equal bytecode, blob.bytecode
      assert_equal script_name, blob.script_name
    end
  end
end
