# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require_relative "../../../../lib/shopify-cli/script/infrastructure/script_builder.rb"

describe ShopifyCli::ScriptModule::Infrastructure::NoopBuilder do
  let(:script_name) { "foo" }
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "package": "@shopify/extension-point-as-fake",
        "version": "*",
        "sdk-version": "*"
      }
    }
  end
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("discount", extension_point_config) }
  let(:script_root) do
    "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}"\
    "/#{extension_point.type}/#{script_name}"
  end
  let(:language) { "js" }
  let(:configuration) { MiniTest::Mock.new }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_id, script_name, extension_point, language) }

  subject { ShopifyCli::ScriptModule::Infrastructure::NoopBuilder.new(script) }

  describe "build" do
    it "should read the source file" do
      File.expects(:read).with(script.filename)
      subject.build
    end
  end
end
