# frozen_string_literal: true

require "test_helper"
require "fakefs/safe"

describe ShopifyCli::ScriptModule::Domain::WasmBlob do
  let(:id) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH}/discount/myscript/myscript.ts" }
  let(:extension_point) { Minitest::Mock.new }
  let(:script_name) { "foo_script" }
  let(:bytecode) { "(module)" }
  let(:shop_id) { 1 }
  let(:wasm_blob) { ShopifyCli::ScriptModule::Domain::WasmBlob.new(id, extension_point, script_name, bytecode) }
  let(:script_service) { Minitest::Mock.new }
  let(:extension_point_type) { "discount" }
  let(:extension_point_schema_file) { "discount" }
  let(:file) { "file" }

  describe ".new" do
    subject { wasm_blob }
    it "should construct new WasmBlob" do
      assert_equal id, subject.id
      assert_equal script_name, subject.script_name
      assert_equal bytecode, subject.bytecode
    end
  end

  describe ".deploy" do
    subject { wasm_blob.deploy(script_service, shop_id) }
    it "should open write to build.wasm and deploy" do
      extension_point.expect(:type, extension_point_type)
      extension_point.expect(:schema_file, extension_point_schema_file)
      FakeFS do
        script_service.expect(:deploy, nil) do |ep_type, ep_schema_file, scr_name, file, id|
          ep_type == extension_point_type &&
          ep_schema_file == extension_point_schema_file &&
          scr_name == script_name &&
          file.path == "build.wasm" &&
          id == shop_id &&
          bytecode == File.read(File.expand_path("build.wasm"))
        end
        subject
      end
    end
  end
end
