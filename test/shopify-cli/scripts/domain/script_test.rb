# frozen_string_literal: true

require "test_helper"
require "tmpdir"

describe ShopifyCli::ScriptModule::Domain::Script do
  let(:source_path) { ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script }
  let(:script_id) { "#{source_path}/discount/myscript/myscript.ts" }
  let(:language) { "ts" }
  let(:configuration) { MiniTest::Mock.new }
  let(:extension_point) { Object.new }
  let(:script_name) { "myscript" }
  let(:code) { "int i" }
  let(:script_name) { "myscript" }
  let(:wasm_file) { Minitest::Mock.new }

  describe ".new" do
    subject { script.new(script_id, script_name, extension_point, configuration, language) }
    it "should construct new Script" do
      assert_equal script_id, subject.id
      assert_equal script_name, subject.name
      assert_equal extension_point, subject.extension_point
      assert_equal language, subject.language
    end
  end
end
